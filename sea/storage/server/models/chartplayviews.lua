local Result = require("sea.chart.Result")
local Gamemode = require("sea.chart.Gamemode")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local int_rates = require("libchart.int_rates")
local json = require("web.json")

---@type rdb.ModelOptions
local chartplayviews = {}

chartplayviews.types = {
	nearest = "boolean",
	result = Result,
	mode = Gamemode,
	custom = "boolean",
	columns_order = json,
	modifiers = json,
	tap_only = "boolean",
	rate = int_rates,
	timings = Timings,
	healths = Healths,
	chartmeta_timings = Timings,
	chartmeta_healths = Healths,
}

return chartplayviews
