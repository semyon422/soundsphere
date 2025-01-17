local IChartfilesRepo = require("sea.chart.repos.IChartfilesRepo")

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
	for _, p in ipairs(self.chartfiles) do
		if p.hash == hash then
			return p
		end
	end
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function FakeChartfilesRepo:createChartfile(chartfile)
	table.insert(self.chartfiles, chartfile)
	chartfile.id = #self.chartfiles
	return chartfile
end

return FakeChartfilesRepo
