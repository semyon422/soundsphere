local QueryFragments = require("rizu.library.sql.QueryFragments")
local chartplayviews = require("rizu.library.models.chartplayviews")

---@type rdb.ModelOptions
local chartplayviews_no_preview = {}

chartplayviews_no_preview.subquery = "SELECT "
	.. QueryFragments.FIELDS_IDS .. ", "
	.. QueryFragments.FIELDS_CHARTPLAY_STAT .. ", "
	.. QueryFragments.FIELDS_CHARTFILE_SET .. ", "
	.. QueryFragments.FIELDS_CHARTFILE .. ", "
	.. QueryFragments.FIELDS_CHARTPLAY .. ", "
	.. QueryFragments.FIELDS_CHARTMETA .. ", "
	.. QueryFragments.FIELDS_CHARTMETA_USER_DATA .. ", "
	.. QueryFragments.FIELDS_CHARTDIFF
	.. QueryFragments.JOINS_CHARTFILES_METAS_SETS
	.. QueryFragments.JOINS_CHARTDIFF
	.. [[
INNER JOIN chartplays ON
chartmetas.hash = chartplays.hash AND
chartmetas.`index` = chartplays.`index` AND
chartdiffs.modifiers = chartplays.modifiers AND
chartdiffs.rate = chartplays.rate
GROUP BY
chartfile_set_id,
chartfile_id,
chartmeta_id,
chartdiff_id,
chartplay_id
]]

chartplayviews_no_preview.types = chartplayviews.types
chartplayviews_no_preview.relations = chartplayviews.relations
chartplayviews_no_preview.from_db = chartplayviews.from_db

return chartplayviews_no_preview
