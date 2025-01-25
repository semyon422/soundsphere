local IChartfilesRepo = require("sea.chart.repos.IChartfilesRepo")
local table_util = require("table_util")

---@class sea.FakeChartfilesRepo: sea.IChartfilesRepo
---@operator call: sea.FakeChartfilesRepo
local FakeChartfilesRepo = IChartfilesRepo + {}

function FakeChartfilesRepo:new()
	---@type sea.Chartfile[]
	self.chartfiles = {}
end

---@return sea.Chartfile[]
function FakeChartfilesRepo:getChartfiles()
	return self.chartfiles
end

---@param hash string
---@return sea.Chartfile?
function FakeChartfilesRepo:getChartfileByHash(hash)
	return table_util.value_by_field(self.chartfiles, "hash", hash)
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function FakeChartfilesRepo:createChartfile(chartfile)
	table.insert(self.chartfiles, chartfile)
	chartfile.id = #self.chartfiles
	return chartfile
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function FakeChartfilesRepo:updateChartfile(chartfile)
	local _chartfile = table_util.value_by_field(self.chartfiles, "id", chartfile.id)
	table_util.copy(chartfile, _chartfile)
	return _chartfile
end

return FakeChartfilesRepo
