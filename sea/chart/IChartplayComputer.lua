local class = require("class")

---@class sea.IChartplayComputer
---@operator call: sea.IChartplayComputer
local IChartplayComputer = class()

---@param chartplay sea.Chartplay
---@return {[1]: sea.Chartplay, [2]: sea.Chartdiff}?
---@return string?
function IChartplayComputer:compute(chartplay)
	return nil, "not implemented"
end

return IChartplayComputer
