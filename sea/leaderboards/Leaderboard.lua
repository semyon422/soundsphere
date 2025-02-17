local class = require("class")

---@class sea.Leaderboard
---@operator call: sea.Leaderboard
---@field id integer
---@field name string
---@field description string
---@field created_at integer
---@field rating_calculator integer enum, difftable
---@field scores_combiner integer enum
---@field scores_combiner_count integer
---@field communities_combiner integer enum
---@field communities_combiner_count integer
---filters
---@field nearest sea.TernaryState
---@field result sea.Result
---@field allow_custom boolean
---@field allow_const boolean
---@field allow_pause boolean
---@field allow_reorder boolean
---@field allow_modifiers boolean
---@field allow_tap_only boolean
---@field allow_free_timings boolean
---@field mode sea.Gamemode
---@field rate "any"|number[]|{min: number, max: number} any, values, range
---@field ranked_lists integer[]
---@field inputmode string[] allowed inputmodes, empty = allow all
local Leaderboard = class()

function Leaderboard:new()
	self.created_at = os.time()
	self.nearest = "any"
	self.result = "fail"
	self.allow_custom = true
	self.allow_pause = true
	self.allow_reorder = true
	self.allow_modifiers = true
	self.allow_tap_only = true
	self.allow_free_timings = true
	self.mode = "mania"
	self.rate = "any"
	self.ranked_lists = {}
	self.inputmode = {}
end

return Leaderboard
