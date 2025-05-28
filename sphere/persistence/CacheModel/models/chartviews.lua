local path_util = require("path_util")
local int_rates = require("libchart.int_rates")
local RateType = require("sea.chart.RateType")
local ChartFormat = require("sea.chart.ChartFormat")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local Gamemode = require("sea.chart.Gamemode")
local Modifiers = require("sea.storage.server.Modifiers")
local MsdDiffData = require("sphere.models.DifficultyModel.MsdDiffData")
local MsdDiffRates = require("sphere.models.DifficultyModel.MsdDiffRates")

local chartviews = {}

chartviews.table_name = "chartviews"

chartviews.types = {
	lamp = "boolean",
	set_is_file = "boolean",
	modifiers = Modifiers,
	rate = int_rates,
	rate_type = RateType,
	format = ChartFormat,
	timings = Timings,
	healths = Healths,
	mode = Gamemode,
	msd_diff_data = MsdDiffData,
	msd_diff_rates = MsdDiffRates,
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
