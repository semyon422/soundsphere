local chartdiffs = require("sphere.persistence.CacheModel.models.chartdiffs")
local int_rates = require("libchart.int_rates")

local scores = {}

scores.table_name = "scores"

scores.types = {
	const = "boolean",
	single = "boolean",
	modifiers = chartdiffs.types.modifiers,
	rate = int_rates,
	rate_type = chartdiffs.types.rate_type,
}

scores.relations = {}

return scores
