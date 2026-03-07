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
local QueryFragments = require("rizu.library.sql.QueryFragments")

---@type rdb.ModelOptions
local chartviews = {}

chartviews.subquery = "SELECT "
	.. QueryFragments.FIELDS_IDS .. ", "
	.. QueryFragments.FIELDS_CHARTPLAY_AGGREGATED .. ", "
	.. QueryFragments.FIELDS_CHARTFILE_SET .. ", "
	.. QueryFragments.FIELDS_CHARTFILE .. ", "
	.. QueryFragments.FIELDS_CHARTMETA .. ", "
	.. QueryFragments.FIELDS_CHARTMETA_USER_DATA .. ", "
	.. QueryFragments.FIELDS_CHARTDIFF .. ", "
	.. QueryFragments.FIELDS_CHARTDIFF_PREVIEW
	.. QueryFragments.JOINS_CHARTFILES_METAS_SETS
	.. QueryFragments.JOINS_CHARTDIFF_DEFAULT
	.. QueryFragments.JOINS_CHARTPLAY
	.. [[
GROUP BY
chartfile_set_id,
chartfile_id,
chartmeta_id
]]

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
