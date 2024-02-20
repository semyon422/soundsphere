local chartdiffs = require("sphere.persistence.CacheModel.models.chartdiffs")

local scores_list = {}

scores_list.table_name = "scores_list"

scores_list.types = {
	const = "boolean",
	single = "boolean",
	modifiers = chartdiffs.types.modifiers,
}

scores_list.relations = {}

return scores_list
