local class = require("class")

---@class sea.IChartplayComputer
---@operator call: sea.IChartplayComputer
local IChartplayComputer = class()

---@param chartplay sea.Chartplay
---@param chartfile sea.Chartfile
---@return {chartplay: sea.Chartplay, chartdiff: sea.Chartdiff, chartmeta: sea.Chartmeta}?
---@return string?
function IChartplayComputer:compute(chartplay, chartfile)
	return nil, "not implemented"
end

---@param chartfile sea.Chartfile
---@param index integer
---@return sea.Chartmeta?
---@return string?
function IChartplayComputer:computeChartmeta(chartfile, index)
	return nil, "not implemented"
end

return IChartplayComputer
