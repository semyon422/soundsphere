local Leaderboard = require("sea.leaderboards.Leaderboard")
local ScoreComb = require("sea.leaderboards.ScoreComb")
local RatingCalc = require("sea.leaderboards.RatingCalc")
local Result = require("sea.chart.Result")
local TernaryState = require("sea.chart.TernaryState")
local Gamemode = require("sea.chart.Gamemode")
local json = require("web.json")

---@type rdb.ModelOptions
local leaderboards = {}

leaderboards.metatable = Leaderboard

leaderboards.types = {
	score_comb = ScoreComb,
	rating_calc = RatingCalc,
	nearest = TernaryState,
	result = Result,
	mode = Gamemode,
	rate = json,
	difftables = json,
	chartmeta_inputmode = json,
	chartdiff_inputmode = json,
	allow_custom = "boolean",
	allow_const = "boolean",
	allow_pause = "boolean",
	allow_reorder = "boolean",
	allow_modifiers = "boolean",
	allow_tap_only = "boolean",
	allow_free_timings = "boolean",
	allow_free_healths = "boolean",
}

return leaderboards
