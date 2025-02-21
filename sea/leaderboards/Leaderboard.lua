local class = require("class")

---@class sea.Leaderboard
---@operator call: sea.Leaderboard
---@field id integer
---@field name string
---@field description string
---@field created_at integer
---rating
---@field rating_calc sea.RatingCalc
---@field scores_comb sea.ScoreComb
---@field scores_comb_count integer
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
---@field allow_free_healths boolean
---@field mode sea.Gamemode
---@field rate "any"|number[]|{min: number, max: number} any, values, range
---@field difftables integer[]
---@field chartmeta_inputmode string[] allowed inputmodes, empty = allow all
---@field chartdiff_inputmode string[] allowed inputmodes, empty = allow all
local Leaderboard = class()

function Leaderboard:new()
	self.created_at = os.time()

	self.rating_calc = "enps"
	self.scores_comb = "avg"
	self.scores_comb_count = 20

	self.nearest = "any"
	self.result = "fail"
	self.allow_custom = true
	self.allow_pause = true
	self.allow_reorder = true
	self.allow_modifiers = true
	self.allow_tap_only = true
	self.allow_free_timings = true
	self.allow_free_healths = true
	self.mode = "mania"
	self.rate = "any"
	self.difftables = {}
	self.chartmeta_inputmode = {}
	self.chartdiff_inputmode = {}
end

return Leaderboard
