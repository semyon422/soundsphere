local QueryFragments = require("rizu.library.sql.QueryFragments")
local chartdiffviews = require("rizu.library.models.chartdiffviews")

---@type rdb.ModelOptions
local chartdiffviews_no_preview = {}

chartdiffviews_no_preview.subquery = "SELECT "
	.. QueryFragments.FIELDS_IDS .. ", "
	.. QueryFragments.FIELDS_CHARTPLAY_AGGREGATED .. ", "
	.. QueryFragments.FIELDS_CHARTFILE_SET .. ", "
	.. QueryFragments.FIELDS_CHARTFILE .. ", "
	.. QueryFragments.FIELDS_CHARTMETA .. ", "
	.. QueryFragments.FIELDS_CHARTMETA_USER_DATA .. ", "
	.. QueryFragments.FIELDS_CHARTDIFF
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

chartdiffviews_no_preview.types = chartdiffviews.types
chartdiffviews_no_preview.relations = chartdiffviews.relations
chartdiffviews_no_preview.from_db = chartdiffviews.from_db

return chartdiffviews_no_preview
