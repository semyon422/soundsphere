local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
local RoomRules = require("sea.multi.RoomRules")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local ReplayBase = require("sea.replays.ReplayBase")

---@class sea.Room
---@operator call: sea.Room
---@field id integer
---@field name string
---@field password string
---@field host_user_id integer
---@field rules sea.RoomRules
---@field chartmeta_key sea.ChartmetaKey
---@field replay_base sea.ReplayBase
local Room = class()

function Room:new()
	self.rules = RoomRules()
	self.chartmeta_key = ChartmetaKey()
	self.replay_base = ReplayBase()
end

Room.isPlaying = false

Room.struct = {
	name = types.name,
	password = types.string,
	rules = function(v) return RoomRules.validate(v) end,
	chartmeta_key = function(v) return ChartmetaKey.validate(v) end,
	replay_base = function(v) return ReplayBase.validate(v) end,
}

local validate_room = valid.struct(Room.struct)

---@return true?
---@return string?
function Room:validate()
	return valid.format(validate_room(self))
end

return Room
