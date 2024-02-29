local class = require("class")

---@class sphere.CacheStatus
---@operator call: sphere.CacheStatus
local CacheStatus = class()

---@param chartRepo sphere.ChartRepo
---@param chartfilesRepo sphere.ChartfilesRepo
function CacheStatus:new(chartRepo, chartfilesRepo)
	self.chartRepo = chartRepo
	self.chartfilesRepo = chartfilesRepo
end

function CacheStatus:update()
	local chartRepo = self.chartRepo
	local chartfilesRepo = self.chartfilesRepo

	self.chartfile_sets = chartfilesRepo:countChartfileSets()
	self.chartfiles = chartfilesRepo:countChartfiles()
	self.chartmetas = chartRepo:countChartmetas()
	self.chartdiffs = chartRepo:countChartdiffs()
end

return CacheStatus
