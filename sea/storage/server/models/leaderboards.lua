local Leaderboard = require("sea.leaderboards.Leaderboard")
local Result = require("sea.chart.Result")
local TernaryState = require("sea.chart.TernaryState")
local Gamemode = require("sea.chart.Gamemode")
local json = require("web.json")

---@type rdb.ModelOptions
local leaderboards = {}

leaderboards.table_name = "leaderboards"

leaderboards.types = {
	nearest = TernaryState,
	result = Result,
	mode = Gamemode,
	rate = json,
	ranked_lists = json,
	chartmeta_inputmode = json,
	chartdiff_inputmode = json,
	allow_custom = "boolean",
	allow_const = "boolean",
	allow_pause = "boolean",
	allow_reorder = "boolean",
	allow_modifiers = "boolean",
	allow_tap_only = "boolean",
	allow_free_timings = "boolean",
}

leaderboards.relations = {}

function leaderboards:from_db()
	return setmetatable(self, Leaderboard)
end

return leaderboards
