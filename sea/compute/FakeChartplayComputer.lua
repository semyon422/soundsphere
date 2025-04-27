local IChartplayComputer = require("sea.compute.IChartplayComputer")

---@class sea.FakeChartplayComputer: sea.IChartplayComputer
---@operator call: sea.FakeChartplayComputer
local FakeChartplayComputer = IChartplayComputer + {}

---@param chartplay sea.Chartplay
---@param chartdiff sea.Chartdiff
---@param chartmeta sea.Chartmeta
function FakeChartplayComputer:new(chartplay, chartdiff, chartmeta)
	self.chartplay = chartplay
	self.chartdiff = chartdiff
	self.chartmeta = chartmeta
end

---@param chartfile_name string
---@param chartfile_data string
---@param index integer
---@param replay sea.Replay
---@return {chartplay_computed: sea.ChartplayComputed, chartdiff: sea.Chartdiff, chartmeta: sea.Chartmeta}?
---@return string?
function FakeChartplayComputer:compute(chartfile_name, chartfile_data, index, replay)
	return {
		chartplay_computed = assert(self.chartplay),
		chartdiff = assert(self.chartdiff),
		chartmeta = assert(self.chartmeta),
	}
end

---@param name string
---@param data string
---@param index integer
---@return sea.Chartmeta?
---@return string?
function FakeChartplayComputer:computeChartmeta(name, data, index)
	return self.chartmeta
end

return FakeChartplayComputer
