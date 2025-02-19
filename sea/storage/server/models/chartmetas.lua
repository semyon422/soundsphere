local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local Chartmeta = require("sea.chart.Chartmeta")

---@type rdb.ModelOptions
local chartmetas = {}

chartmetas.metatable = Chartmeta

chartmetas.types = {
	timings = Timings,
	healths = Healths,
}

return chartmetas
