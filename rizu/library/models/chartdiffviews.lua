local path_util = require("path_util")
local int_rates = require("libchart.int_rates")
local RateType = require("sea.chart.RateType")
local ChartFormat = require("sea.chart.ChartFormat")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local Modifiers = require("sea.storage.server.Modifiers")
local Gamemode = require("sea.chart.Gamemode")
local Subtimings = require("sea.chart.Subtimings")
local IntegerArray = require("sea.storage.server.IntegerArray")
local IntegerArrayOptional = require("sea.storage.server.IntegerArrayOptional")
local MsdDiffData = require("sphere.models.DifficultyModel.MsdDiffData")
local MsdDiffRates = require("sphere.models.DifficultyModel.MsdDiffRates")
local QueryFragments = require("rizu.library.sql.QueryFragments")

---@type rdb.ModelOptions
local chartdiffviews = {}

chartdiffviews.subquery = "SELECT "
	.. QueryFragments.FIELDS_IDS .. ", "
	.. QueryFragments.FIELDS_CHARTPLAY_AGGREGATED .. ", "
	.. QueryFragments.FIELDS_CHARTFILE_SET .. ", "
	.. QueryFragments.FIELDS_CHARTFILE .. ", "
	.. QueryFragments.FIELDS_CHARTMETA .. ", "
	.. QueryFragments.FIELDS_CHARTMETA_USER_DATA .. ", "
	.. QueryFragments.FIELDS_CHARTDIFF .. ", "
	.. QueryFragments.FIELDS_CHARTDIFF_PREVIEW
	.. QueryFragments.JOINS_CHARTFILES_METAS_SETS
	.. QueryFragments.JOINS_CHARTDIFF
	.. QueryFragments.JOINS_CHARTPLAY_BY_MODE
	.. [[
GROUP BY
chartfile_set_id,
chartfile_id,
chartmeta_id,
chartdiff_id
]]

chartdiffviews.types = {
	lamp = "boolean",
	set_is_file = "boolean",
	format = ChartFormat,

	nearest = "boolean",
	pass = "boolean",
	mode = Gamemode,
	custom = "boolean",
	columns_order = IntegerArrayOptional,
	modifiers = Modifiers,
	judges = IntegerArray,
	tap_only = "boolean",
	const = "boolean",
	rate = int_rates,
	timings = Timings,
	subtimings = Subtimings,
	healths = Healths,
	rate_type = RateType,

	msd_diff_data = MsdDiffData,
	msd_diff_rates = MsdDiffRates,
}

chartdiffviews.relations = {}

function chartdiffviews:from_db()
	local dir = self.set_dir
	if not self.set_is_file then
		dir = path_util.join(dir, self.set_name)
	end
	self.dir = dir
	self.path = path_util.join(dir, self.chartfile_name)
end

return chartdiffviews
