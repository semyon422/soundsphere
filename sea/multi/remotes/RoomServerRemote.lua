local class = require("class")
local valid = require("valid")
local RoomUpdate = require("sea.multi.RoomUpdate")

---@class sea.RoomServerRemote: sea.IMultiplayerServerRemote
---@operator call: sea.RoomServerRemote
local RoomServerRemote = class()

---@param mp_server sea.MultiplayerServer
function RoomServerRemote:new(mp_server)
	self.mp_server = mp_server
end

---@param room_values sea.RoomUpdate
---@return boolean?
---@return string?
function RoomServerRemote:updateRoom(room_values)
	local ok, err = valid.format(RoomUpdate.validate(room_values))
	if not ok then
		return nil, "validate room update: " .. err
	end
	setmetatable(room_values, RoomUpdate)

	self.mp_server:updateLocalRoom(self.user, room_values)
end

---@param user_id any
function RoomServerRemote:setHost(user_id) end

---@param user_id any
function RoomServerRemote:kickUser(user_id) end

function RoomServerRemote:startMatch()
	self.mp_server:startLocalMatch(self.user)
end

function RoomServerRemote:stopMatch() end

return RoomServerRemote
