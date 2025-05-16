local class = require("class")

---@class sea.RoomRules
---@operator call: sea.RoomRules
local RoomRules = class()

function RoomRules:new()
	self.free_rate = false
end

return RoomRules
