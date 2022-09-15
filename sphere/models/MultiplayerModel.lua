local Class = require("aqua.util.Class")
local aquatimer = require("aqua.timer")
local aquathread = require("aqua.thread")
local enet = require("enet")
local MessagePack = require("MessagePack")
local remote = require("aqua.util.remote")

remote.encode = MessagePack.pack
remote.decode = MessagePack.unpack

local MultiplayerModel = Class:new()

MultiplayerModel.construct = function(self)
	self.status = "disconnected"
	self.rooms = {}
	self.users = {}
	self.roomUsers = {}
	self.modifiers = {}
	self.notechart = {}
	self.roomMessages = {}

	self.isPlaying = false
end

MultiplayerModel.load = function(self)
	self.host = enet.host_create()
	self.stopRefresh = aquatimer.every(0.1, self.refresh, self)
end

MultiplayerModel.unload = function(self)
	self:disconnect()
	self.host:flush()
	self.host = nil
	self.stopRefresh()
end

MultiplayerModel.refresh = function(self)
	local peer = self.peer
	local room = self.room
	if not peer or not room then
		return
	end

	self.roomUsers = peer.getRoomUsers() or {}

	local scoreSystem = self.game.rhythmModel.scoreEngine.scoreSystem
	if not scoreSystem.entry then
		return
	end
	peer._setScore({
		accuracy = scoreSystem.entry.accuracy,
		combo = scoreSystem.base.combo,
		failed = scoreSystem.hp:isFailed(),
	})
end

local toipAsync = aquathread.async(function(host)
	local socket = require("socket")
	return socket.dns.toip(host)
end)

local connecting = false
MultiplayerModel.connect = aquathread.coro(function(self)
	if connecting or self.status == "connecting" then
		return
	end
	self.status = "connecting"
	connecting = true
	local url = self.game.configModel.configs.urls.multiplayer
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

MultiplayerModel.disconnect = function(self)
	if self.status == "connected" then
		self.server:disconnect()
		self.status = "disconnecting"
	end
end

MultiplayerModel.addMessage = function(self, message)
	table.insert(self.roomMessages, message)
end

MultiplayerModel.isHost = function(self)
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
	self.peer._setModifiers(self.game.modifierModel.config)
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
	self.peer._setModifiers(self.game.modifierModel.config)
end)

local async_read = aquathread.async(function(...) return love.filesystem.read(...) end)

MultiplayerModel.pushNotechart = remote.wrap(function(self)
	if not self.peer then
		return
	end

	local nc = self.game.selectModel.noteChartItem
	if not nc then
		return
	end

	local path = nc.path
	local osuSetId
	if path:find("%.osu$") then
		local content = async_read(path)
		osuSetId = tonumber(content:match("BeatmapSetID:%s*(%d+)"))
	end

	self.noteChartItem = {
		setId = nc.setId,
		noteChartId = nc.noteChartId,
		noteChartDataId = nc.noteChartDataId,
	}
	self.notechart = {
		hash = nc.hash,
		index = nc.index,
		format = nc.format,
		title = nc.title,
		artist = nc.artist,
		source = nc.source,
		tags = nc.tags,
		name = nc.name,
		creator = nc.creator,
		level = nc.level,
		inputMode = nc.inputMode,
		noteCount = nc.noteCount,
		length = nc.length,
		bpm = nc.bpm,
		difficulty = nc.difficulty,
		longNoteRatio = nc.longNoteRatio,
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
	local api = self.game.onlineModel.webApi.api

	local key = self.peer.login()
	if not key then
		return
	elseif key == "" then
		local user = self.game.configModel.configs.online.user
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

MultiplayerModel.peerconnected = function(self, peer)
	print("connected")
	self.status = "connected"
	self.peer = peer

	self:login()
end

MultiplayerModel.peerdisconnected = function(self, peer)
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

MultiplayerModel.update = function(self)
	if not self.server then
		return
	end

	local host = self.host
	local event = host:service()
	while event do
		if event.type == "connect" then
			self:peerconnected(remote.peer(event.peer))
		elseif event.type == "receive" then
			remote.receive(event, self.handlers)
		elseif event.type == "disconnect" then
			self:peerdisconnected(remote.peer(event.peer))
		end
		event = host:service()
	end

	remote.update()
end

MultiplayerModel.downloadNoteChart = function(self)
	if self.downloadingBeatmap then
		return
	end

	self.downloadingBeatmap = {
		setId = self.notechart.osuSetId,
		status = "",
	}
	self.game.osudirectModel:downloadBeatmapSet(self.downloadingBeatmap, function()
		self.downloadingBeatmap.status = "done"
		self:pullNotechart()
	end)
end

return MultiplayerModel
