local class = require("class")

---@class sea.RoomRules
---@operator call: sea.RoomRules
local RoomRules = class()

-- "true" means player can change it

function RoomRules:new()
	self.chart = false

	self.modifiers = false
	self.rate = false -- rate, rate_type
	self.mode = false

	self.nearest = false
	self.tap_only = false
	self.timings = false -- timings, subtimings, timing_values
	self.healths = false
	self.columns_order = false

	self.custom = false
	self.const = false
end

return RoomRules
