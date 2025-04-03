local class = require("class")
local table_util = require("table_util")
local valid = require("valid")
local types = require("sea.shared.types")
local RatingCalc = require("sea.leaderboards.RatingCalc")
local ScoreComb = require("sea.leaderboards.ScoreComb")
local TernaryState = require("sea.chart.TernaryState")
local Result = require("sea.chart.Result")
local Gamemode = require("sea.chart.Gamemode")

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
---@field chartmeta_inputmode string[] allowed inputmodes, empty = allow all
---@field chartdiff_inputmode string[] allowed inputmodes, empty = allow all
---@field leaderboard_difftables sea.LeaderboardDifftable[]
local Leaderboard = class()

function Leaderboard:new()
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
	self.chartmeta_inputmode = {}
	self.chartdiff_inputmode = {}
	self.leaderboard_difftables = {}
end

---@param rate any
---@return boolean
local function is_valid_rate(rate)
	if type(rate) ~= "table" then
		return rate == "any"
	end
	---@cast rate {[any]: [any]}
	if rate[1] then
		if not table_util.is_array_of(rate, "number") then
			return false
		end
	elseif next(rate) then
		for k, v in pairs(rate) do
			if k ~= "min" and k ~= "max" or type(v) ~= "number" then
				return false
			end
		end
	end
	return true
end

local validate_leaderboard = valid.struct({
	name = types.name,
	description = types.description,
	rating_calc = types.new_enum(RatingCalc),
	scores_comb = types.new_enum(ScoreComb),
	scores_comb_count = types.count,
	nearest = types.new_enum(TernaryState),
	result = types.new_enum(Result),
	allow_custom = types.boolean,
	allow_const = types.boolean,
	allow_pause = types.boolean,
	allow_reorder = types.boolean,
	allow_modifiers = types.boolean,
	allow_tap_only = types.boolean,
	allow_free_timings = types.boolean,
	allow_free_healths = types.boolean,
	rate = is_valid_rate,
	mode = types.new_enum(Gamemode),
	chartmeta_inputmode = valid.array(types.name, 10),
	chartdiff_inputmode = valid.array(types.name, 10),
	leaderboard_difftables = valid.array(valid.struct({difftable_id = types.index}), 10),
})

---@return true?
---@return string[]?
function Leaderboard:validate()
	local ok, errs = validate_leaderboard(self)
	if not ok then
		return nil, valid.flatten(errs)
	end
	return true
end

return Leaderboard
