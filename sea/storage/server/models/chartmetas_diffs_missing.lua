local table_util = require("table_util")
local chartmetas = require("sea.storage.server.models.chartmetas")

---@type rdb.ModelOptions
local chartmetas_diffs_missing = table_util.copy(chartmetas)

chartmetas_diffs_missing.subquery = [[
SELECT
chartmetas.id,
chartmetas.hash,
chartmetas.`index`
FROM chartmetas
LEFT JOIN chartdiffs ON
chartmetas.hash = chartdiffs.hash AND
chartmetas.`index` = chartdiffs.`index` AND
chartdiffs.modifiers = "" AND
chartdiffs.rate = 1000
WHERE
chartdiffs.id IS NULL
]]

return chartmetas_diffs_missing
