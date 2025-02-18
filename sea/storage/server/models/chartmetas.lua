local Timings = require("sea.chart.Timings")
local Chartmeta = require("sea.chart.Chartmeta")

---@type rdb.ModelOptions
local chartmetas = {}

chartmetas.metatable = Chartmeta

chartmetas.types = {
	timings = Timings,
}

return chartmetas
