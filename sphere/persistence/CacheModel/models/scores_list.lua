local chartdiffs = require("sphere.persistence.CacheModel.models.chartdiffs")
local int_rates = require("libchart.int_rates")

local scores_list = {}

scores_list.table_name = "scores_list"

scores_list.types = {
	const = "boolean",
	single = "boolean",
	modifiers = chartdiffs.types.modifiers,
	rate = int_rates,
	is_exp_rate = "boolean",
}

scores_list.relations = {}

return scores_list
