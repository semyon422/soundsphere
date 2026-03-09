local class = require("class")

---@class chartbase.IChartEncoder
---@operator call: chartbase.IChartEncoder
local IChartEncoder = class()

---@param chart_chartmetas {chart: ncdk2.Chart, chartmeta: sea.Chartmeta}[]
---@return string
function IChartEncoder:encode(chart_chartmetas)
	return ""
end

return IChartEncoder
