local class = require("class")

---@class sphere.CacheStatus
---@operator call: sphere.CacheStatus
local CacheStatus = class()

---@param chartRepo sphere.ChartRepo
function CacheStatus:new(chartRepo)
	self.chartRepo = chartRepo
end

function CacheStatus:update()
	local chartRepo = self.chartRepo

	self.chartfile_sets = chartRepo:countChartfileSets()
	self.chartfiles = chartRepo:countChartfiles()
	self.chartmetas = chartRepo:countChartmetas()
	self.chartdiffs = chartRepo:countChartdiffs()
end

return CacheStatus
