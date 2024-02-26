local path_util = require("path_util")
local chartdiffs = require("sphere.persistence.CacheModel.models.chartdiffs")
local int_rates = require("libchart.int_rates")

local chartviews = {}

chartviews.table_name = "chartviews"

chartviews.types = {
	lamp = "boolean",
	set_is_file = "boolean",
	modifiers = chartdiffs.types.modifiers,
	rate = int_rates,
	is_exp_rate = "boolean",
}

chartviews.relations = {}

function chartviews:from_db()
	local dir = self.set_dir
	if not self.set_is_file then
		dir = path_util.join(dir, self.set_name)
	end
	self.dir = dir
	self.path = path_util.join(dir, self.chartfile_name)
end

return chartviews
