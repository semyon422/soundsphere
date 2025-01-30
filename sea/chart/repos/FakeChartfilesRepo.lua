local IChartfilesRepo = require("sea.chart.repos.IChartfilesRepo")
local TestModel = require("rdb.TestModel")

---@class sea.FakeChartfilesRepo: sea.IChartfilesRepo
---@operator call: sea.FakeChartfilesRepo
local FakeChartfilesRepo = IChartfilesRepo + {}

function FakeChartfilesRepo:new()
	self.chartfiles = TestModel()
end

---@return sea.Chartfile[]
function FakeChartfilesRepo:getChartfiles()
	return self.chartfiles:select()
end

---@param hash string
---@return sea.Chartfile?
function FakeChartfilesRepo:getChartfileByHash(hash)
	return self.chartfiles:find({hash = hash})
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function FakeChartfilesRepo:createChartfile(chartfile)
	return self.chartfiles:create(chartfile)
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function FakeChartfilesRepo:updateChartfile(chartfile)
	return self.chartfiles:update(chartfile, {id = chartfile.id})[1]
end

return FakeChartfilesRepo
