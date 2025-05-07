local path_util = require("path_util")
local chartdiffs = require("sphere.persistence.CacheModel.models.chartdiffs")
local int_rates = require("libchart.int_rates")
local RateType = require("sea.chart.RateType")
local ChartFormat = require("sea.chart.ChartFormat")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local Gamemode = require("sea.chart.Gamemode")

local chartplayviews = {}

chartplayviews.table_name = "chartplayviews"

chartplayviews.types = {
	lamp = "boolean",
	set_is_file = "boolean",
	modifiers = chartdiffs.types.modifiers,
	rate = int_rates,
	rate_type = RateType,
	format = ChartFormat,
	timings = Timings,
	healths = Healths,
	mode = chartdiffs.types.mode,
}

chartplayviews.relations = {}

function chartplayviews:from_db()
	local dir = self.set_dir
	if not self.set_is_file then
		dir = path_util.join(dir, self.set_name)
	end
	self.dir = dir
	self.path = path_util.join(dir, self.chartfile_name)
end

return chartplayviews
