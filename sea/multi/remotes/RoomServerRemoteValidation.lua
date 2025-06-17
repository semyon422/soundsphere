local class = require("class")

---@class sea.RoomServerRemoteValidation: sea.RoomServerRemote
---@operator call: sea.RoomServerRemoteValidation
local RoomServerRemoteValidation = class()

---@param remote sea.RoomServerRemote
function RoomServerRemoteValidation:new(remote)
	self.remote = remote
end

---@param room_values sea.RoomUpdate
---@return boolean?
---@return string?
function RoomServerRemoteValidation:updateRoom(room_values)
	return self.remote:updateRoom(room_values)
end

---@param user_id integer
function RoomServerRemoteValidation:kickUser(user_id)
	self.remote:kickLocalUser(user_id)
end

function RoomServerRemoteValidation:startMatch()
	self.remote:startLocalMatch()
end

function RoomServerRemoteValidation:stopMatch()
	self.remote:stopMatch()
end

return RoomServerRemoteValidation
