local chartdiffs = require("sphere.persistence.CacheModel.models.chartdiffs")
local int_rates = require("libchart.int_rates")
local RateType = require("sea.chart.RateType")

local scores = {}

scores.table_name = "scores"

scores.types = {
	const = "boolean",
	single = "boolean",
	modifiers = chartdiffs.types.modifiers,
	rate = int_rates,
	rate_type = RateType,
}

scores.relations = {}

return scores
