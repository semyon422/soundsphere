local class = require("class")
local MultiplayerUserServerRemote = require("sea.multi.remotes.MultiplayerUserServerRemote")
local RoomServerRemote = require("sea.multi.remotes.RoomServerRemote")

---@class sea.MultiplayerServerRemote: sea.IMultiplayerServerRemote
---@operator call: sea.MultiplayerServerRemote
local MultiplayerServerRemote = class()

---@param mp_server sea.MultiplayerServer
function MultiplayerServerRemote:new(mp_server)
	self.mp_server = mp_server
	self.mp_user = MultiplayerUserServerRemote(mp_server)
	self.mp_room = RoomServerRemote(mp_server)
end

---@param ... any
function MultiplayerServerRemote:print(...)
	print(...)
end

---@return sea.Room[]
function MultiplayerServerRemote:getRooms()
	return self.mp_server:getRooms()
end

---@return sea.User[]
function MultiplayerServerRemote:getUsers()
	return self.mp_server:getUsers()
end

---@return sea.User
function MultiplayerServerRemote:getUser()
	return self.user
end

---@return integer?
function MultiplayerServerRemote:getRoomId()
	return self.mp_server:getRoomId(self.user)
end

---@return string?
function MultiplayerServerRemote:login()
	-- if peer_users[peer.id] then
	-- 	return
	-- end

	-- if config.offlineMode then
	return ""
	-- end

	-- local key = tostring(math.random(1000000, 9999999))
	-- peer_by_key[key] = peer

	-- return key
end

---@param user_name string
function MultiplayerServerRemote:loginOffline(user_name)
	self.mp_server:loginOffline(self.user, user_name)
end

---@param name string
---@param password string
---@return sea.Room?
---@return string?
function MultiplayerServerRemote:createRoom(name, password)
	if type(name) ~= "string" then
		return nil, "invalid name"
	end
	if type(password) ~= "string" then
		return nil, "invalid password"
	end
	return self.mp_server:createRoom(self.user, name, password)
end

---@param room_id integer
---@param password string
---@return true?
---@return string?
function MultiplayerServerRemote:joinRoom(room_id, password)
	if type(room_id) ~= "number" or math.floor(room_id) ~= room_id then
		return nil, "invalid room_id"
	end
	if type(password) ~= "string" then
		return nil, "invalid password"
	end
	return self.mp_server:joinRoom(self.user, room_id, password)
end

---@return true?
---@return string?
function MultiplayerServerRemote:leaveRoom()
	return self.mp_server:leaveRoom(self.user)
end

---@return sea.Room?
function MultiplayerServerRemote:getCurrentRoom()
	return self.mp_server:getCurrentRoom(self.user)
end

return MultiplayerServerRemote
