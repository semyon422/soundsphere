local class = require("class")

---@class sea.IChartplayComputer
---@operator call: sea.IChartplayComputer
local IChartplayComputer = class()

---@param chartfile_name string
---@param chartfile_data string
---@param index integer
---@param replay sea.Replay
---@return {chartplay: sea.Chartplay, chartdiff: sea.Chartdiff, chartmeta: sea.Chartmeta}?
---@return string?
function IChartplayComputer:compute(chartfile_name, chartfile_data, index, replay)
	return nil, "not implemented"
end

---@param name string
---@param data string
---@param index integer
---@return sea.Chartmeta?
---@return string?
function IChartplayComputer:computeChartmeta(name, data, index)
	return nil, "not implemented"
end

return IChartplayComputer
