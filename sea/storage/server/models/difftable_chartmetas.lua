local DifftableChartmeta = require("sea.difftables.DifftableChartmeta")

---@type rdb.ModelOptions
local difftable_chartmetas = {}

difftable_chartmetas.subquery = [[
SELECT
	difftable_chartmetas.*,
	chartmetas.id AS chartmeta_id
FROM difftable_chartmetas
INNER JOIN chartmetas ON
	chartmetas.hash = difftable_chartmetas.hash AND
	chartmetas.`index` = difftable_chartmetas.`index`
]]

difftable_chartmetas.metatable = DifftableChartmeta

difftable_chartmetas.types = {
	is_deleted = "boolean",
}

difftable_chartmetas.relations = {
	chartmeta = {belongs_to = "chartmetas", key = "chartmeta_id"},
	user = {belongs_to = "users", key = "user_id"},
	difftable = {belongs_to = "difftables", key = "difftable_id"},
}

return difftable_chartmetas
