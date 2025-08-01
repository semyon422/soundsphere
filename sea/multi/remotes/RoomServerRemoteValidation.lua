local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
local RoomUpdate = require("sea.multi.RoomUpdate")

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
	assert(valid.format(RoomUpdate.validate(room_values)))
	return self.remote:updateRoom(room_values)
end

---@param user_id integer
function RoomServerRemoteValidation:kickUser(user_id)
	assert(types.integer(user_id))
	self.remote:kickUser(user_id)
end

function RoomServerRemoteValidation:startMatch()
	self.remote:startMatch()
end

function RoomServerRemoteValidation:stopMatch()
	self.remote:stopMatch()
end

return RoomServerRemoteValidation
