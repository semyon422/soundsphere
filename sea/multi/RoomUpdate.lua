local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
local RoomRules = require("sea.multi.RoomRules")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local ReplayBase = require("sea.replays.ReplayBase")

---@class sea.RoomUpdate
---@operator call: sea.RoomUpdate
---@field id integer?
---@field name string?
---@field password string?
---@field rules sea.RoomRules?
---@field chartmeta_key sea.ChartmetaKey?
---@field replay_base sea.ReplayBase?
local RoomUpdate = class()

RoomUpdate.struct = {
	name = valid.optional(types.name),
	password = valid.optional(types.string),
	rules = valid.optional(function(v) return RoomRules.validate(v) end),
	chartmeta_key = valid.optional(function(v) return ChartmetaKey.validate(v) end),
	replay_base = valid.optional(function(v) return ReplayBase.validate(v) end),
}

local validate_room_update = valid.struct(RoomUpdate.struct)

---@return true?
---@return string?
function RoomUpdate:validate()
	return valid.format(validate_room_update(self))
end

return RoomUpdate
