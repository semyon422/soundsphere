local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local ChartFormat = require("sea.chart.ChartFormat")
local Chartmeta = require("sea.chart.Chartmeta")

---@type rdb.ModelOptions
local chartmetas = {}

chartmetas.metatable = Chartmeta

chartmetas.types = {
	timings = Timings,
	healths = Healths,
	format = ChartFormat,
}

return chartmetas
