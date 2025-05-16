local class = require("class")

---@class sea.MultiplayerAccess
---@operator call: sea.MultiplayerAccess
local MultiplayerAccess = class()

---@param user sea.User
---@return boolean
function MultiplayerAccess:canCreateRoom(user)
	return not user:isAnon()
end

---@param user sea.User
---@param room sea.Room
---@return boolean
function MultiplayerAccess:canKickUser(user, room, target_user_id)
	return user.id == target_user_id or self:canUpdateRoom(user, room)
end

---@param user sea.User
---@param room sea.Room
---@return boolean
function MultiplayerAccess:canUpdateRoom(user, room)
	return user.id == room.host_user_id
end

---@param user sea.User
---@param room sea.Room
---@return boolean
function MultiplayerAccess:canJoinRoom(user, room)
	return true
end

return MultiplayerAccess
