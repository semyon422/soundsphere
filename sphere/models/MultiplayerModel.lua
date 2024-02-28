local class = require("class")
local delay = require("delay")
local thread = require("thread")
local enet = require("enet")
local remote = require("remote")

remote.set_coder(require("string.buffer"))

---@class sphere.MultiplayerModel
---@operator call: sphere.MultiplayerModel
local MultiplayerModel = class()

---@param rhythmModel sphere.RhythmModel
---@param configModel sphere.ConfigModel
---@param selectModel sphere.SelectModel
---@param onlineModel sphere.OnlineModel
---@param osudirectModel sphere.OsudirectModel
---@param playContext sphere.PlayContext
function MultiplayerModel:new(rhythmModel, configModel, selectModel, onlineModel, osudirectModel, playContext)
	self.rhythmModel = rhythmModel
	self.configModel = configModel
	self.selectModel = selectModel
	self.onlineModel = onlineModel
	self.osudirectModel = osudirectModel
	self.playContext = playContext

	self.status = "disconnected"
	self.rooms = {}
	self.users = {}
	self.roomUsers = {}
	self.modifiers = {}
	self.notechart = {}
	self.roomMessages = {}

	self.isPlaying = false
end

function MultiplayerModel:load()
	self.host = enet.host_create()
	self.stopRefresh = delay.every(0.1, self.refresh, self)
end

function MultiplayerModel:unload()
	self:disconnect()
	self.host:flush()
	self.host = nil
	self.stopRefresh()
end

function MultiplayerModel:refresh()
	local peer = self.peer
	local room = self.room
	if not peer or not room then
		return
	end

	self.roomUsers = peer.getRoomUsers() or {}

	local scoreSystem = self.rhythmModel.scoreEngine.scoreSystem
	if not scoreSystem.base then
		return
	end
	peer._setScore({
		accuracy = scoreSystem.normalscore.accuracyAdjusted,
		combo = scoreSystem.base.combo,
		failed = scoreSystem.hp:isFailed(),
	})
end

local toipAsync = thread.async(function(host)
	local socket = require("socket")
	return socket.dns.toip(host)
end)

local connecting = false
MultiplayerModel.connect = thread.coro(function(self)
	if connecting or self.status == "connecting" then
		return
	end
	self.status = "connecting"
	connecting = true
	local url = self.configModel.configs.urls.multiplayer
	local host, port = url:match("^(.+):(.-)$")
	local ip = toipAsync(host or "")
	local status, err = pcall(self.host.connect, self.host, ("%s:%s"):format(ip, port))
	if not status then
		self.status = err
		return
	end
	self.server = err
	connecting = false
end)

function MultiplayerModel:disconnect()
	if self.status == "connected" then
		self.server:disconnect()
		self.status = "disconnecting"
	end
end

---@param message string
function MultiplayerModel:addMessage(message)
	table.insert(self.roomMessages, message)
end

---@return boolean
function MultiplayerModel:isHost()
	local room = self.room
	if not room then
		return false
	end
	return room.hostPeerId == self.user.peerId
end

MultiplayerModel.switchReady = remote.wrap(function(self)
	self.peer.switchReady()
	self.user = self.peer.getUser()
end)

MultiplayerModel.setIsPlaying = remote.wrap(function(self, value)
	if not self.peer then
		return
	end
	self.isPlaying = value
	self.peer._setIsPlaying(value)
end)

MultiplayerModel.sendMessage = remote.wrap(function(self, message)
	self.peer._sendMessage(message)
end)

MultiplayerModel.startMatch = remote.wrap(function(self)
	self.peer._startMatch()
end)

MultiplayerModel.stopMatch = remote.wrap(function(self)
	self.peer._stopMatch()
end)

MultiplayerModel.setHost = remote.wrap(function(self, peerId)
	self.peer._setHost(peerId)
end)

MultiplayerModel.kickUser = remote.wrap(function(self, peerId)
	self.peer._kickUser(peerId)
end)

MultiplayerModel.setFreeModifiers = remote.wrap(function(self, isFreeModifiers)
	if not self:isHost() then
		return
	end
	self.room.isFreeModifiers = isFreeModifiers
	self.peer.setFreeModifiers(isFreeModifiers)
	self.room = self.peer.getRoom()
end)

MultiplayerModel.setFreeNotechart = remote.wrap(function(self, isFreeNotechart)
	if not self:isHost() then
		return
	end
	self.room.isFreeNotechart = isFreeNotechart
	self.peer.setFreeNotechart(isFreeNotechart)
	self.room = self.peer.getRoom()
end)

MultiplayerModel.createRoom = remote.wrap(function(self, name, password)
	self.room = self.peer.createRoom(name, password)
	if not self.room then
		return
	end
	self.selectedRoom = nil
	self.peer._setModifiers(self.playContext.modifiers)
	self:pushNotechart()
end)

MultiplayerModel.joinRoom = remote.wrap(function(self, password)
	self.room = self.peer.joinRoom(self.selectedRoom.id, password)
	if not self.room then
		return
	end
	self.selectedRoom = nil
end)

MultiplayerModel.leaveRoom = remote.wrap(function(self)
	if self.peer.leaveRoom() then
		self.room = nil
		self.selectedRoom = nil
		self.roomUsers = {}
		self.roomMessages = {}
	end
end)

MultiplayerModel.pushModifiers = remote.wrap(function(self)
	if not self.peer then
		return
	end
	self.peer._setModifiers(self.playContext.modifiers)
end)

local async_read = thread.async(function(...) return love.filesystem.read(...) end)

MultiplayerModel.pushNotechart = remote.wrap(function(self)
	if not self.peer then
		return
	end

	local chartview = self.selectModel.chartview
	if not chartview then
		return
	end

	local path = chartview.location_path
	local osuSetId
	if path:find("%.osu$") then
		local content = async_read(path)
		osuSetId = tonumber(content:match("BeatmapSetID:%s*(%d+)"))
	end

	self.chartview = {
		chartfile_set_id = chartview.chartfile_set_id,
		chartfile_id = chartview.chartfile_id,
		chartmeta_id = chartview.chartmeta_id,
	}
	self.notechart = {
		hash = chartview.hash,
		index = chartview.index,
		format = chartview.format,
		title = chartview.title,
		artist = chartview.artist,
		source = chartview.source,
		tags = chartview.tags,
		name = chartview.name,
		creator = chartview.creator,
		level = chartview.level,
		inputnode = chartview.inputmode,
		notes_count = chartview.notes_count,
		duration = chartview.duration,
		tempo = chartview.tempo,
		difficulty = chartview.difficulty,
		longNoteRatio = chartview.longNoteRatio,
		osuSetId = osuSetId,
	}
	self.peer._setNotechart(self.notechart)
end)

MultiplayerModel.pullModifiers = remote.wrap(function(self)
	local modifiers = self.peer.getRoomModifiers()
	if not modifiers then
		return
	end
	self.handlers.set(self.peer, "modifiers", modifiers)
end)

MultiplayerModel.pullNotechart = remote.wrap(function(self)
	local notechart = self.peer.getRoomNotechart()
	if not notechart then
		return
	end
	self.handlers.set(self.peer, "notechart", notechart)
end)

MultiplayerModel.login = remote.wrap(function(self)
	local api = self.onlineModel.webApi.api

	local key = self.peer.login()
	if not key then
		return
	elseif key == "" then
		local user = self.configModel.configs.online.user
		local id, name = 0, "username"
		if user and user.name then
			id = user.id
			name = user.name
		end
		return self.peer.loginOffline(id, name)
	end

	print("POST " .. api.auth.multiplayer)
	local response, code, headers = api.auth.multiplayer:_post({key = key})
end)

---@param peer any
function MultiplayerModel:peerconnected(peer)
	print("connected")
	self.status = "connected"
	self.peer = peer

	self:login()
end

---@param peer any
function MultiplayerModel:peerdisconnected(peer)
	print("disconnected")
	self.status = "disconnected"
	self.peer = nil

	self.rooms = {}
	self.users = {}
	self.roomUsers = {}
	self.roomMessages = {}
	self.room = nil
	self.selectedRoom = nil
	self.user = nil
end

function MultiplayerModel:update()
	if not self.server then
		return
	end

	local host = self.host
	local event = host:service()
	while event do
		if event.type == "connect" then
			self:peerconnected(remote.peer(event.peer))
		elseif event.type == "receive" then
			remote.receive(event.data, event.peer, self.handlers)
		elseif event.type == "disconnect" then
			self:peerdisconnected(remote.peer(event.peer))
		end
		event = host:service()
	end

	remote.update()
end

function MultiplayerModel:downloadNoteChart()
	local setId = self.notechart.osuSetId
	if self.downloadingBeatmap or not setId then
		return
	end

	self.downloadingBeatmap = {
		id = setId,
		status = "",
	}
	self.osudirectModel:downloadBeatmapSet(self.downloadingBeatmap, function()
		self.downloadingBeatmap.status = "done"
		self:pullNotechart()
	end)
end

return MultiplayerModel
