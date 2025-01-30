local IChartdiffsRepo = require("sea.chart.repos.IChartdiffsRepo")
local TestModel = require("rdb.TestModel")

---@class sea.FakeChartdiffsRepo: sea.IChartdiffsRepo
---@operator call: sea.FakeChartdiffsRepo
local FakeChartdiffsRepo = IChartdiffsRepo + {}

function FakeChartdiffsRepo:new()
	self.chartdiffs = TestModel()
end

---@return sea.Chartdiff[]
function FakeChartdiffsRepo:getChartdiffs()
	return self.chartdiffs:select()
end

---@param chartkey sea.Chartkey
---@return sea.Chartdiff?
function FakeChartdiffsRepo:getChartdiffByChartkey(chartkey)
	return self.chartdiffs:find({
		hash = chartkey.hash,
		index = chartkey.index,
		modifiers = chartkey.modifiers,
		rate = chartkey.rate,
		mode = chartkey.mode,
	})
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function FakeChartdiffsRepo:createChartdiff(chartdiff)
	return self.chartdiffs:create(chartdiff)
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function FakeChartdiffsRepo:updateChartdiff(chartdiff)
	return self.chartdiffs:update(chartdiff, {id = chartdiff.id})[1]
end

return FakeChartdiffsRepo
