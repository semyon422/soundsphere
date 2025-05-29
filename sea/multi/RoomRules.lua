local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")

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

RoomRules.struct = {
	chart = types.boolean,
	modifiers = types.boolean,
	rate = types.boolean,
	mode = types.boolean,
	nearest = types.boolean,
	tap_only = types.boolean,
	timings = types.boolean,
	healths = types.boolean,
	columns_order = types.boolean,
	custom = types.boolean,
	const = types.boolean,
}

local validate_room_rules = valid.struct(RoomRules.struct)

---@return true?
---@return string|valid.Errors?
function RoomRules:validate()
	return validate_room_rules(self)
end

return RoomRules
