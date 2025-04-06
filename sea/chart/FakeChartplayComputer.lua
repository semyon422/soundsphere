local IChartplayComputer = require("sea.chart.IChartplayComputer")

---@class sea.FakeChartplayComputer: sea.IChartplayComputer
---@operator call: sea.FakeChartplayComputer
local FakeChartplayComputer = IChartplayComputer + {}

---@param chartdiff sea.Chartdiff
---@param chartmeta sea.Chartmeta
function FakeChartplayComputer:new(chartdiff, chartmeta)
	self.chartdiff = chartdiff
	self.chartmeta = chartmeta
end

---@param chartplay sea.Chartplay
---@param chartfile sea.Chartfile
---@return {chartplay: sea.Chartplay, chartdiff: sea.Chartdiff, chartmeta: sea.Chartmeta}?
---@return string?
function FakeChartplayComputer:compute(chartplay, chartfile)
	return {
		chartplay = chartplay,
		chartdiff = assert(self.chartdiff),
		chartmeta = assert(self.chartmeta),
	}
end

---@param chartfile sea.Chartfile
---@param index integer
---@return sea.Chartmeta?
---@return string?
function FakeChartplayComputer:computeChartmeta(chartfile, index)
	return self.chartmeta
end

return FakeChartplayComputer
