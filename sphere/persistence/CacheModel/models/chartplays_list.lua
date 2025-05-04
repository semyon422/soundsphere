local chartdiffs = require("sphere.persistence.CacheModel.models.chartdiffs")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local Healths = require("sea.chart.Healths")
local RateType = require("sea.chart.RateType")
local int_rates = require("libchart.int_rates")
local json = require("web.json")

local chartplays_list = {}

chartplays_list.table_name = "chartplays_list"

chartplays_list.types = {
	nearest = "boolean",
	pass = "boolean",
	mode = chartdiffs.types.mode,
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

chartplays_list.relations = {}

return chartplays_list
