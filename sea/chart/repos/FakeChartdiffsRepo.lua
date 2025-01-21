local IChartdiffsRepo = require("sea.chart.repos.IChartdiffsRepo")
local table_util = require("table_util")

---@class sea.FakeChartdiffsRepo: sea.IChartdiffsRepo
---@operator call: sea.FakeChartdiffsRepo
local FakeChartdiffsRepo = IChartdiffsRepo + {}

function FakeChartdiffsRepo:new()
	---@type sea.Chartdiff[]
	self.chartdiffs = {}
end

---@return sea.Chartdiff[]
function FakeChartdiffsRepo:getChartdiffs()
	return self.chartdiffs
end

---@param chartkey sea.Chartkey
---@return sea.Chartdiff?
function FakeChartdiffsRepo:getChartdiffByChartkey(chartkey)
	for _, chartdiff in ipairs(self.chartdiffs) do
		if chartdiff:equalsChartkey(chartkey) then
			return chartdiff
		end
	end
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function FakeChartdiffsRepo:createChartdiff(chartdiff)
	table.insert(self.chartdiffs, chartdiff)
	chartdiff.id = #self.chartdiffs
	return chartdiff
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function FakeChartdiffsRepo:updateChartdiff(chartdiff)
	local _chartdiff = table_util.value_by_field(self.chartdiffs, "id", chartdiff.id)
	table_util.copy(chartdiff, _chartdiff)
	return _chartdiff
end

return FakeChartdiffsRepo
