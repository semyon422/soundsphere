local IChartplayComputer = require("sea.chart.IChartplayComputer")

---@class sea.FakeChartplayComputer: sea.IChartplayComputer
---@operator call: sea.FakeChartplayComputer
local FakeChartplayComputer = IChartplayComputer + {}

---@param chartdiff sea.Chartdiff
function FakeChartplayComputer:new(chartdiff)
	self.chartdiff = chartdiff
end

---@param chartplay sea.Chartplay
---@return {[1]: sea.Chartplay, [2]: sea.Chartdiff}?
---@return string?
function FakeChartplayComputer:compute(chartplay)
	return {chartplay, self.chartdiff}
end

return FakeChartplayComputer
