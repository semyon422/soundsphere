local Class = require("aqua.util.Class")
local aquatimer = require("aqua.timer")
local enet = require("enet")
local MessagePack = require("MessagePack")
local remote = require("aqua.util.remote")
local deepclone = require("aqua.util.deepclone")

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
	self.notechartChanged = false

	self.isPlaying = false
	self.handlers = {
		set = function(peer, key, value)
			self[key] = value
			if key == "notechart" then
				self.notechartChanged = true
			elseif key == "modifiers" then
				self.modifierModel:setConfig(value)
				self.configModel.configs.modifier = value
				self.modifiers = deepclone(value)
			end
		end,
		startMatch = function(peer)
			if not self.isPlaying and self.noteChartItem then
				if not self.room.isFreeModifiers then
					local modifiers = deepclone(self.modifiers)
					self.modifierModel:setConfig(modifiers)
					self.configModel.configs.modifier = modifiers
				end
				if not self.room.isFreeNotechart then
					self.selectModel:setConfig(self.noteChartItem)
				end
				self.gameController.selectController:playNoteChart()
			end
		end,
		stopMatch = function(peer)
			if self.isPlaying then
				self.gameController.gameplayController:quit()
			end
		end,
		addMessage = function(peer, message)
			table.insert(self.roomMessages, message)
		end,
	}
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

	local scoreSystem = self.gameController.rhythmModel.scoreEngine.scoreSystem
	if not scoreSystem.entry then
		return
	end
	peer._setScore({
		accuracy = scoreSystem.entry.accuracy,
		combo = scoreSystem.base.combo,
		failed = scoreSystem.hp.failed,
	})
end

MultiplayerModel.connect = function(self)
	local urls = self.gameController.configModel.configs.urls
	if self.status == "disconnected" then
		self.server = self.host:connect(urls.multiplayer)
		self.status = "connecting"
	end
end

MultiplayerModel.disconnect = function(self)
	if self.status == "connected" then
		self.server:disconnect()
		self.status = "disconnecting"
	end
end

MultiplayerModel.isHost = function(self)
	local room = self.room
	if not room then
		return false
	end
	return room.hostPeerId == self.user.peerId
end

MultiplayerModel.findNotechart = remote.wrap(function(self)
	self.noteChartSetLibraryModel:findNotechart(self.notechart.hash or "", self.notechart.index or 0)
	local items = self.noteChartSetLibraryModel.items

	local item = items[1]
	if item then
		self.noteChartItem = {
			setId = item.setId,
			noteChartId = item.noteChartId,
			noteChartDataId = item.noteChartDataId,
		}
		self.selectModel:setConfig(item)
		self.selectModel:pullNoteChartSet(true)
		self.peer.setNotechartFound(true)
		return
	end
	self.selectModel:setConfig({
		setId = 0,
		noteChartId = 0,
		noteChartDataId = 0,
	})
	self.noteChartItem = nil
	self.selectModel:pullNoteChartSet(true)
	self.peer.setNotechartFound(false)
end)

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
	self.peer._setModifiers(self.modifierModel.config)
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
	if not self:isHost() then
		return
	end
	self.peer._setModifiers(self.modifierModel.config)
end)

MultiplayerModel.pushNotechart = remote.wrap(function(self)
	if not self:isHost() then
		return
	end
	local nc = self.selectModel.noteChartItem
	if not nc then
		return
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
	}
	self.peer._setNotechart(self.notechart)
end)

MultiplayerModel.pullModifiers = remote.wrap(function(self)
	local modifiers = self.peer.getRoomModifiers()
	if not modifiers then
		return
	end
	self.modifierModel:setConfig(modifiers)
	self.configModel.configs.modifier = modifiers
end)

MultiplayerModel.pullNotechart = remote.wrap(function(self)
	local notechart = self.peer.getRoomNotechart()
	if not notechart then
		return
	end
	self.notechart = notechart
	self:findNotechart()
end)

MultiplayerModel.login = remote.wrap(function(self)
	local api = self.onlineModel.webApi.api

	local key = self.peer.login()
	if not key then
		return
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

	if not self.room or self:isHost() then
		return
	end

	if self.notechartChanged then
		self.notechartChanged = false
		if not self.room.isFreeNotechart then
			self:findNotechart()
		end
	end
end

return MultiplayerModel
