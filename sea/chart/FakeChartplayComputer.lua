local IChartplayComputer = require("sea.chart.IChartplayComputer")
local Chartdiff = require("sea.chart.Chartdiff")

---@class sea.FakeChartplayComputer: sea.IChartplayComputer
---@operator call: sea.FakeChartplayComputer
local FakeChartplayComputer = IChartplayComputer + {}

---@param chartplay sea.Chartplay
---@return {[1]: sea.Chartplay, [2]: sea.Chartdiff}?
---@return string?
function FakeChartplayComputer:compute(chartplay)
	local chartdiff = Chartdiff()
	chartdiff.notes_hash = chartplay.notes_hash

	chartplay.compute_state = "valid"

	chartdiff.hash = chartplay.hash
	chartdiff.index = chartplay.index
	chartdiff.modifiers = chartplay.modifiers
	chartdiff.rate = chartplay.rate
	chartdiff.rate_type = chartplay.rate_type
	chartdiff.mode = chartplay.mode

	return {chartplay, chartdiff}
end

return FakeChartplayComputer
