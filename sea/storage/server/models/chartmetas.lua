local Timings = require("sea.chart.Timings")

---@type rdb.ModelOptions
local chartmetas = {}

chartmetas.table_name = "chartmetas"

chartmetas.types = {
	timings = Timings,
}

chartmetas.relations = {}

return chartmetas
