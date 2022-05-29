local Class = require("aqua.util.Class")
local aquatimer = require("aqua.timer")
local enet = require("enet")
local MessagePack = require("MessagePack")
local remote = require("aqua.util.remote")

remote.encode = MessagePack.pack
remote.decode = MessagePack.unpack

local MultiplayerModel = Class:new()

MultiplayerModel.construct = function(self)
	self.rooms = {}
	self.users = {}
	self.roomUsers = {}
	self.modifiers = {}
	self.notechart = {}
	self.notechartChanged = false
	self.handlers = {
		set = function(peer, key, value)
			self[key] = value
			if key == "notechart" then
				self.notechartChanged = true
			end
		end,
		startMatch = function(peer)
			self.gameController.selectController:playNoteChart()
		end,
	}
end

MultiplayerModel.load = function(self)
	self.host = enet.host_create()
	self.stopRefresh = false
	aquatimer.every(1, self.refresh, self)
end

MultiplayerModel.unload = function(self)
	self.host:flush()
	self.host = nil
	self.stopRefresh = true
end

MultiplayerModel.refresh = function(self)
	if self.stopRefresh then
		return true
	end

	local peer = self.peer
	if not peer then
		return
	end

	-- self.rooms = peer.getRooms() or {}
	-- self.users = peer.getUsers() or {}
	-- self.room = peer.getRoom()
end

MultiplayerModel.connect = function(self)
	self.server = self.host:connect("localhost:9000")
end

MultiplayerModel.disconnect = function(self)
	self.server:disconnect()
end

MultiplayerModel.findNotechart = remote.wrap(function(self)
	self.noteChartSetLibraryModel:findNotechart(self.notechart.hash or "", self.notechart.index or 0)
	self.selectModel:scrollNoteChartSet(0)
	if self.selectModel.noteChartItem then
		self.selectModel:setConfig(self.selectModel.noteChartItem)
		self.peer.setNotechartFound(true)
		return
	end
	self.peer.setNotechartFound(false)
end)

MultiplayerModel.switchReady = remote.wrap(function(self)
	self.peer.switchReady()
	self.user = self.peer.getUser()
end)

MultiplayerModel.startMatch = remote.wrap(function(self)
	self.peer._startMatch()
end)

MultiplayerModel.setFreeModifiers = remote.wrap(function(self, isFreeModifiers)
	self.room.isFreeModifiers = isFreeModifiers
	self.peer.setFreeModifiers(isFreeModifiers)
	self.room = self.peer.getRoom()
end)

MultiplayerModel.createRoom = remote.wrap(function(self, name, password)
	self.room = self.peer.createRoom(name, password)
	if not self.room then
		return
	end
	self.peer._setModifiers(self.modifierModel.config)
end)

MultiplayerModel.joinRoom = remote.wrap(function(self, password)
	self.room = self.peer.joinRoom(self.selectedRoom.id, password)
end)

MultiplayerModel.leaveRoom = remote.wrap(function(self)
	if self.peer.leaveRoom() then
		self.room = nil
		self.selectedRoom = nil
		self.roomUsers = {}
	end
end)

MultiplayerModel.pushModifiers = remote.wrap(function(self)
	if not self.room then
		return
	end
	self.peer._setModifiers(self.modifierModel.config)
end)

MultiplayerModel.pushNotechart = remote.wrap(function(self)
	if not self.room then
		return
	end
	local nc = self.selectModel.noteChartItem
	if not nc then
		return
	end
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
	self.peer = peer

	self:login()
end

MultiplayerModel.peerdisconnected = function(self, peer)
	print("disconnected")
	self.peer = nil

	self.rooms = {}
	self.users = {}
	self.roomUsers = {}
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

	local room = self.room
	if room and room.hostPeerId ~= self.user.peerId and not room.isFreeModifiers then
		self.modifierModel.config = self.modifiers
	end
	if room and room.hostPeerId ~= self.user.peerId and self.notechartChanged then
		self.notechartChanged = false
		self:findNotechart()
	end
end

return MultiplayerModel
