local QueryFragments = require("rizu.library.sql.QueryFragments")
local chartviews = require("rizu.library.models.chartviews")

---@type rdb.ModelOptions
local chartviews_no_preview = {}

chartviews_no_preview.subquery = "SELECT "
	.. QueryFragments.FIELDS_IDS .. ", "
	.. QueryFragments.FIELDS_CHARTPLAY_AGGREGATED .. ", "
	.. QueryFragments.FIELDS_CHARTFILE_SET .. ", "
	.. QueryFragments.FIELDS_CHARTFILE .. ", "
	.. QueryFragments.FIELDS_CHARTMETA .. ", "
	.. QueryFragments.FIELDS_CHARTMETA_USER_DATA .. ", "
	.. QueryFragments.FIELDS_CHARTDIFF
	.. QueryFragments.JOINS_CHARTFILES_METAS_SETS
	.. QueryFragments.JOINS_CHARTDIFF_DEFAULT
	.. QueryFragments.JOINS_CHARTPLAY
	.. [[
GROUP BY
chartfile_set_id,
chartfile_id,
chartmeta_id
]]

chartviews_no_preview.types = chartviews.types
chartviews_no_preview.relations = chartviews.relations
chartviews_no_preview.from_db = chartviews.from_db

return chartviews_no_preview
