local class = require("class")

---@class sphere.CacheStatus
---@operator call: sphere.CacheStatus
local CacheStatus = class()

---@param chartfilesRepo sphere.ChartfilesRepo
---@param chartsRepo sea.ChartsRepo
function CacheStatus:new(chartfilesRepo, chartsRepo)
	self.chartfilesRepo = chartfilesRepo
	self.chartsRepo = chartsRepo
end

function CacheStatus:update()
	self.chartfile_sets = self.chartfilesRepo:countChartfileSets()
	self.chartfiles = self.chartfilesRepo:countChartfiles()
	self.chartmetas = self.chartsRepo:countChartmetas()
	self.chartdiffs = self.chartsRepo:countChartdiffs()
	self.chartplays = self.chartsRepo:countChartplays()
end

return CacheStatus
