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
	self.handlers = {set = function(peer, key, value)
		self[key] = value
	end}
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

MultiplayerModel.switchReady = remote.wrap(function(self)
	self.peer.switchReady()
	self.user = self.peer.getUser()
end)

MultiplayerModel.startMatch = remote.wrap(function(self)
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
end

return MultiplayerModel
