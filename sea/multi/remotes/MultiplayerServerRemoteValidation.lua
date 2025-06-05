local class = require("class")
local MultiplayerUserServerRemoteValidation = require("sea.multi.remotes.MultiplayerUserServerRemoteValidation")
local RoomServerRemoteValidation = require("sea.multi.remotes.RoomServerRemoteValidation")

---@class sea.MultiplayerServerRemoteValidation: sea.MultiplayerServerRemote
---@operator call: sea.MultiplayerServerRemoteValidation
local MultiplayerServerRemoteValidation = class()

---@param remote sea.MultiplayerServerRemote
function MultiplayerServerRemoteValidation:new(remote)
	self.remote = remote
	self.mp_user = MultiplayerUserServerRemoteValidation(remote.mp_user)
	self.mp_room = RoomServerRemoteValidation(remote.mp_room)
end

---@param ... any
function MultiplayerServerRemoteValidation:print(...)
	self.remote:print(...)
end

---@return sea.Room[]
function MultiplayerServerRemoteValidation:getRooms()
	return self.remote:getRooms()
end

---@return sea.User[]
function MultiplayerServerRemoteValidation:getUsers()
	return self.remote:getUsers()
end

---@return sea.User
function MultiplayerServerRemoteValidation:getUser()
	return self.remote:getUser()
end

---@return integer?
function MultiplayerServerRemoteValidation:getRoomId()
	return self.remote:getRoomId()
end

---@return string?
function MultiplayerServerRemoteValidation:login()
	return self.remote:login()
end

---@param user_name string
---@return integer
function MultiplayerServerRemoteValidation:loginOffline(user_name)
	return self.remote:loginOffline(user_name)
end

---@param room_values sea.Room
---@return integer?
---@return string?
function MultiplayerServerRemoteValidation:createRoom(room_values)
	return self.remote:createRoom(room_values)
end

---@param room_id integer
---@param password string
---@return boolean?
---@return string?
function MultiplayerServerRemoteValidation:joinRoom(room_id, password)
	return self.remote:joinRoom(room_id, password)
end

---@return boolean?
---@return string?
function MultiplayerServerRemoteValidation:leaveRoom()
	return self.remote:leaveRoom()
end

---@return sea.Room?
function MultiplayerServerRemoteValidation:getCurrentRoom()
	return self.remote:getCurrentRoom()
end

return MultiplayerServerRemoteValidation
