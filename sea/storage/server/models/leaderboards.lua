local Leaderboard = require("sea.leaderboards.Leaderboard")
local ScoreComb = require("sea.leaderboards.ScoreComb")
local RatingCalc = require("sea.leaderboards.RatingCalc")
local JudgesResult = require("sea.chart.JudgesResult")
local TernaryState = require("sea.chart.TernaryState")
local Gamemode = require("sea.chart.Gamemode")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local stbl = require("stbl")

---@type rdb.ModelOptions
local leaderboards = {}

leaderboards.metatable = Leaderboard

leaderboards.types = {
	score_comb = ScoreComb,
	rating_calc = RatingCalc,
	nearest = TernaryState,
	pass = "boolean",
	judges = JudgesResult,
	mode = Gamemode,
	rate = stbl,
	difftables = stbl,
	chartmeta_inputmode = stbl,
	chartdiff_inputmode = stbl,
	timings = Timings,
	healths = Healths,
	allow_custom = "boolean",
	allow_const = "boolean",
	allow_pause = "boolean",
	allow_reorder = "boolean",
	allow_modifiers = "boolean",
	allow_tap_only = "boolean",
	allow_free_timings = "boolean",
	allow_free_healths = "boolean",
}

leaderboards.relations = {
	leaderboard_difftables = {has_many = "leaderboard_difftables", key = "leaderboard_id"},
	leaderboard_users = {has_many = "leaderboard_users", key = "leaderboard_id"},
}

return leaderboards
