local class = require("class")

---@class sea.MultiplayerServerRemote: sea.IServerRemote
---@operator call: sea.MultiplayerServerRemote
local MultiplayerServerRemote = class()

---@param multiplayer sea.Multiplayer
function MultiplayerServerRemote:new(multiplayer)
	self.multiplayer = multiplayer
end

---@param ... any
function MultiplayerServerRemote:print(...)
	print(...)
end

---@return sea.Room[]
function MultiplayerServerRemote:getRooms()
	return self.multiplayer:getRooms()
end

---@return sea.User[]
function MultiplayerServerRemote:getUsers()
	return self.multiplayer:getUsers(self.ip, self.port)
end

---@return sea.User
function MultiplayerServerRemote:getUser()
	return self.user
end

---@return integer?
function MultiplayerServerRemote:getRoomId()
	return self.multiplayer:getRoomId(self.user)
end

---@param room_values sea.Room
---@return integer?
---@return string?
function MultiplayerServerRemote:createRoom(room_values)
	return self.multiplayer:createRoom(self.user, room_values, self.ip, self.port)
end

---@param room_id integer
---@param password string
---@return boolean?
---@return string?
function MultiplayerServerRemote:joinRoom(room_id, password)
	return self.multiplayer:joinRoom(self.user, room_id, password, self.ip, self.port)
end

---@return boolean?
---@return string?
function MultiplayerServerRemote:leaveRoom()
	return self.multiplayer:leaveRoom(self.user, self.ip, self.port)
end

---@return sea.Room?
function MultiplayerServerRemote:getCurrentRoom()
	return self.multiplayer:getCurrentRoom(self.user)
end

---@param chartplay_computed sea.ChartplayComputed
function MultiplayerServerRemote:setChartplayComputed(chartplay_computed)
	self.multiplayer:setChartplayComputed(self.user, chartplay_computed, self.ip, self.port)
end

function MultiplayerServerRemote:switchReady()
	self.multiplayer:switchReady(self.user, self.ip, self.port)
end

---@param found boolean
function MultiplayerServerRemote:setChartFound(found)
	self.multiplayer:setChartFound(self.user, found, self.ip, self.port)
	return true
end

---@param is_playing boolean
function MultiplayerServerRemote:setPlaying(is_playing)
	self.multiplayer:setPlaying(self.user, is_playing, self.ip, self.port)
end

---@param msg string
function MultiplayerServerRemote:sendMessage(msg)
	self.multiplayer:sendLocalMessage(self.user, msg, self.ip, self.port)
end

---@param room_values sea.RoomUpdate
---@return boolean?
---@return string?
function MultiplayerServerRemote:updateRoom(room_values)
	return self.multiplayer:updateLocalRoom(self.user, room_values, self.ip, self.port)
end

---@param user_id integer
function MultiplayerServerRemote:kickUser(user_id)
	self.multiplayer:kickLocalUser(self.user, user_id, self.ip, self.port)
end

function MultiplayerServerRemote:startMatch()
	self.multiplayer:startLocalMatch(self.user, self.ip, self.port)
end

function MultiplayerServerRemote:stopMatch()
	self.multiplayer:stopLocalMatch(self.user, self.ip, self.port)
end

return MultiplayerServerRemote
