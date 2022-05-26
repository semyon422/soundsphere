local Class = require("aqua.util.Class")
local remote = require("aqua.util.remote")
local enet = require("enet")

local MultiplayerModel = Class:new()

MultiplayerModel.construct = function(self)
	self.rooms = {}
	self.users = {}
end

MultiplayerModel.load = function(self)
	self.host = enet.host_create()
end

MultiplayerModel.unload = function(self)
	self.host:flush()
	self.host = nil
end

MultiplayerModel.connect = function(self)
	self.server = self.host:connect("localhost:9000")
end

MultiplayerModel.disconnect = function(self)
	self.server:disconnect()
	self.rooms = {}
	self.users = {}
	self.room = nil
	self.selectedRoom = nil
	self.user = nil
end

MultiplayerModel.updateRooms = remote.wrap(function(self)
	self.rooms = self.peer.getRooms()
end)

MultiplayerModel.updateUsers = remote.wrap(function(self)
	self.users = self.peer.getUsers()
end)

MultiplayerModel.createRoom = remote.wrap(function(self, user, password)
	self.room = self.peer.createRoom(user, password)
	self.rooms = self.peer.getRooms()
end)

MultiplayerModel.joinRoom = remote.wrap(function(self, password)
	self.room = self.peer.joinRoom(self.selectedRoom.id, password)
end)

MultiplayerModel.leaveRoom = remote.wrap(function(self)
	local isLeft = self.peer.leaveRoom()
	if isLeft then
		self.room = nil
	end
	self.rooms = self.peer.getRooms()
end)

MultiplayerModel.login = remote.wrap(function(self)
	local api = self.onlineModel.webApi.api

	local key = self.peer.login()
	if not key then
		return
	end

	print("POST " .. api.auth.multiplayer)
	local response, code, headers = api.auth.multiplayer:_post({key = key})

	self.user = self.peer.getUser()
	self.users = self.peer.getUsers()
end)

MultiplayerModel.peerconnected = function(self, peer)
	print("connected")
	self.peer = peer

	self:updateRooms()
	self:updateUsers()
end

MultiplayerModel.peerdisconnected = function(self, peer)
	print("disconnected")
	self.peer = nil
end

MultiplayerModel.update = function(self)
	local host = self.host
	local event = host:service()
	while event do
		if event.type == "connect" then
			self:peerconnected(remote.peer(event.peer))
		elseif event.type == "receive" then
			remote.receive(event)
		elseif event.type == "disconnect" then
			self:peerdisconnected(remote.peer(event.peer))
		end
		event = host:service()
	end
end

return MultiplayerModel
