local chartdiffs = require("sphere.persistence.CacheModel.models.chartdiffs")
local int_rates = require("libchart.int_rates")
local RateType = require("sea.chart.RateType")
local Result = require("sea.chart.Result")
local Gamemode = require("sea.chart.Gamemode")
local Chartplay = require("sea.chart.Chartplay")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local Healths = require("sea.chart.Healths")
local RateType = require("sea.chart.RateType")
local int_rates = require("libchart.int_rates")
local json = require("web.json")

---@type rdb.ModelOptions
local chartplays = {}

chartplays.table_name = "chartplays"

chartplays.metatable = Chartplay

chartplays.types = {
	nearest = "boolean",
	result = Result,
	mode = Gamemode,
	custom = "boolean",
	columns_order = json,
	modifiers = chartdiffs.types.modifiers,
	judges = json,
	tap_only = "boolean",
	const = "boolean",
	rate = int_rates,
	timings = Timings,
	subtimings = Subtimings,
	healths = Healths,
	rate_type = RateType,
}

return chartplays
