local table_util = require("table_util")
local chartplays = require("sea.storage.server.models.chartplays")

---@type rdb.ModelOptions
local chartplays_list = table_util.copy(chartplays)

chartplays_list.subquery = [[
SELECT
chartplays.id AS chartplay_id,
chartplays.*,
chartmetas.id AS chartmeta_id,
chartdiffs.id AS chartdiff_id,
chartdiffs.enps_diff AS difficulty,
chartdiffs.hash,
chartdiffs.`index`,
chartdiffs.modifiers,
chartdiffs.rate,
chartdiffs.mode,
chartdiffs.inputmode,
chartdiffs.duration,
chartdiffs.start_time,
chartdiffs.notes_count,
chartdiffs.judges_count,
(chartdiffs.judges_count - chartdiffs.notes_count) * 1.0 / chartdiffs.notes_count AS long_notes_ratio,
chartdiffs.note_types_count,
chartdiffs.density_data,
chartdiffs.sv_data,
chartdiffs.enps_diff,
chartdiffs.osu_diff,
chartdiffs.msd_diff,
chartdiffs.msd_diff_data,
chartdiffs.user_diff,
chartdiffs.user_diff_data,
chartdiffs.notes_preview
FROM chartplays
LEFT JOIN chartdiffs ON
chartplays.hash = chartdiffs.hash AND
chartplays.`index` = chartdiffs.`index` AND
chartplays.modifiers = chartdiffs.modifiers AND
chartplays.rate = chartdiffs.rate
LEFT JOIN chartmetas ON
chartplays.hash = chartmetas.hash AND
chartplays.`index` = chartmetas.`index`
]]

return chartplays_list
