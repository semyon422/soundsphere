local chartdiffs = require("sphere.persistence.CacheModel.models.chartdiffs")
local int_rates = require("libchart.int_rates")
local RateType = require("sea.chart.RateType")

local chartplays_list = {}

chartplays_list.table_name = "chartplays_list"

chartplays_list.types = {
	const = "boolean",
	single = "boolean",
	modifiers = chartdiffs.types.modifiers,
	rate = int_rates,
	rate_type = RateType,
}

chartplays_list.relations = {}

return chartplays_list
