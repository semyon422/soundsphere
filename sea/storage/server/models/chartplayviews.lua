local Chartplayview = require("sea.chart.Chartplayview")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")

local table_util = require("table_util")
local chartplays = require("sea.storage.server.models.chartplays")

---@type rdb.ModelOptions
local chartplayviews = {}

chartplayviews.subquery = [[
SELECT
chartplays.id AS chartplay_id,
chartdiffs.id AS chartdiff_id,
chartmetas.id AS chartmeta_id,
difftable_chartmetas.difftable_id AS difftable_id,
difftable_chartmetas.level AS difftable_level,
chartmetas.level AS chartmeta_level,
chartmetas.timings AS chartmeta_timings,
chartmetas.healths AS chartmeta_healths,
chartmetas.inputmode AS chartmeta_inputmode,
chartdiffs.inputmode AS chartdiff_inputmode,
chartdiffs.notes_count,
chartplays.*
FROM chartplays
LEFT JOIN chartmetas ON
chartmetas.hash = chartplays.hash AND
chartmetas.`index` = chartplays.`index`
LEFT JOIN chartdiffs ON
chartdiffs.hash = chartplays.hash AND
chartdiffs.`index` = chartplays.`index` AND
chartdiffs.mode = chartplays.mode AND
chartdiffs.modifiers = chartplays.modifiers AND
chartdiffs.rate = chartplays.rate
LEFT JOIN difftable_chartmetas ON
difftable_chartmetas.hash = chartplays.hash AND
difftable_chartmetas.`index` = chartplays.`index`
]]

chartplayviews.metatable = Chartplayview

chartplayviews.types = {
	chartmeta_timings = Timings,
	chartmeta_healths = Healths,
}
table_util.copy(chartplays.types, chartplayviews.types)

chartplayviews.relations = {
	chartdiff = {belongs_to = "chartdiffs", key = "chartdiff_id"},
	chartmeta = {belongs_to = "chartmetas", key = "chartmeta_id"},
}

return chartplayviews
