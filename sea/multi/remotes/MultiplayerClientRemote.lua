local class = require("class")

---@class sea.MultiplayerClientRemote
---@operator call: sea.MultiplayerClientRemote
local MultiplayerClientRemote = class()

---@param client sea.MultiplayerClient
function MultiplayerClientRemote:new(client)
	self.client = client
end

---@param ... any
function MultiplayerClientRemote:print(...)
	print(...)
end

---@param rooms sea.Room[]
function MultiplayerClientRemote:setRooms(rooms)
	self.client:setRooms(rooms)
end

---@param room_users sea.RoomUser[]
function MultiplayerClientRemote:setRoomUsers(room_users)
	self.client:setRoomUsers(room_users)
end

---@param users sea.User[]
function MultiplayerClientRemote:setUsers(users)
	self.client:setUsers(users)
end

function MultiplayerClientRemote:startMatch()
	self.client:startClientMatch()
end

function MultiplayerClientRemote:stopMatch()
	self.client:stopClientMatch()
end

---@param msg string
function MultiplayerClientRemote:addMessage(msg)
	self.client:addMessage(msg)
end

function MultiplayerClientRemote:syncRules()
	self.client:syncRules()
end

function MultiplayerClientRemote:syncChart()
	self.client:syncChart()
end

function MultiplayerClientRemote:syncReplayBase()
	self.client:syncReplayBase()
end

return MultiplayerClientRemote
