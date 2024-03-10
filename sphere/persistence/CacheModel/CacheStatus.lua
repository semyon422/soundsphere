local class = require("class")

---@class sphere.CacheStatus
---@operator call: sphere.CacheStatus
local CacheStatus = class()

---@param chartfilesRepo sphere.ChartfilesRepo
---@param chartmetasRepo sphere.ChartmetasRepo
---@param chartdiffsRepo sphere.ChartdiffsRepo
function CacheStatus:new(chartfilesRepo, chartmetasRepo, chartdiffsRepo)
	self.chartfilesRepo = chartfilesRepo
	self.chartmetasRepo = chartmetasRepo
	self.chartdiffsRepo = chartdiffsRepo
end

function CacheStatus:update()
	self.chartfile_sets = self.chartfilesRepo:countChartfileSets()
	self.chartfiles = self.chartfilesRepo:countChartfiles()
	self.chartmetas = self.chartmetasRepo:countChartmetas()
	self.chartdiffs = self.chartdiffsRepo:countChartdiffs()
end

return CacheStatus
