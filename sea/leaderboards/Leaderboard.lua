local class = require("class")
local table_util = require("table_util")
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

---@param v any
local function is_id(v)
	return type(v) == "number" and v == math.floor(v) and v > 0
end

---@param lb_dt any
local function is_leaderboard_difftable(lb_dt)
	if type(lb_dt) ~= "table" then
		return false
	end
	---@cast lb_dt {[any]: [any]}
	local c = 0
	for k, v in pairs(lb_dt) do
		c = c + 1
		if k ~= "difftable_id" or not is_id(v) then
			return false
		end
	end
	if c ~= 1 then
		return false
	end
	return true
end

---@return true?
---@return string[]?
function Leaderboard:validate()
	local errs = {}

	if type(self.name) ~= "string" or #self.name == 0 then
		table.insert(errs, "invalid name")
	end
	if type(self.description) ~= "string" then
		table.insert(errs, "invalid description")
	end

	if not RatingCalc:encode_safe(self.rating_calc) then
		table.insert(errs, "invalid rating_calc")
	end
	if not ScoreComb:encode_safe(self.scores_comb) then
		table.insert(errs, "invalid scores_comb")
	end
	if type(self.scores_comb_count) ~= "number" or self.scores_comb_count <= 0 then
		table.insert(errs, "invalid scores_comb_count")
	end

	if not TernaryState:encode_safe(self.nearest) then
		table.insert(errs, "invalid nearest")
	end
	if not Result:encode_safe(self.result) then
		table.insert(errs, "invalid result")
	end
	if type(self.allow_custom) ~= "boolean" then
		table.insert(errs, "invalid allow_custom")
	end
	if type(self.allow_const) ~= "boolean" then
		table.insert(errs, "invalid allow_const")
	end
	if type(self.allow_pause) ~= "boolean" then
		table.insert(errs, "invalid allow_pause")
	end
	if type(self.allow_reorder) ~= "boolean" then
		table.insert(errs, "invalid allow_reorder")
	end
	if type(self.allow_modifiers) ~= "boolean" then
		table.insert(errs, "invalid allow_modifiers")
	end
	if type(self.allow_tap_only) ~= "boolean" then
		table.insert(errs, "invalid allow_tap_only")
	end
	if type(self.allow_free_timings) ~= "boolean" then
		table.insert(errs, "invalid allow_free_timings")
	end
	if type(self.allow_free_healths) ~= "boolean" then
		table.insert(errs, "invalid allow_free_healths")
	end
	if not Gamemode:encode_safe(self.mode) then
		table.insert(errs, "invalid mode " .. tostring(self.mode))
	end

	if not is_valid_rate(self.rate) then
		table.insert(errs, "invalid rate")
	end
	if not table_util.is_array_of(self.chartmeta_inputmode, "string") then
		table.insert(errs, "invalid chartmeta_inputmode")
	end
	if not table_util.is_array_of(self.chartdiff_inputmode, "string") then
		table.insert(errs, "invalid chartdiff_inputmode")
	end

	if not table_util.is_array_of(self.leaderboard_difftables, is_leaderboard_difftable) then
		table.insert(errs, "invalid leaderboard_difftables")
	end

	if #errs > 0 then
		return nil, errs
	end

	return true
end

return Leaderboard
