local Result = require("sea.chart.Result")
local TernaryState = require("sea.chart.TernaryState")
local Gamemode = require("sea.chart.Gamemode")
local int_rates = require("libchart.int_rates")
local json = require("web.json")

---@type rdb.ModelOptions
local chartplayviews = {}

chartplayviews.table_name = "chartplayviews"

chartplayviews.types = {
	nearest = TernaryState,
	result = Result,
	mode = Gamemode,
	custom = "boolean",
	columns_order = json,
	modifiers = json,
	tap_only = "boolean",
	rate = int_rates,
}

chartplayviews.relations = {}

return chartplayviews
