local class = require("class")

---@class sea.IChartdiffsRepo
---@operator call: sea.IChartdiffsRepo
local IChartdiffsRepo = class()

---@return sea.Chartdiff[]
function IChartdiffsRepo:getChartdiffs()
	return {}
end

---@param chartkey sea.Chartkey
---@return sea.Chartdiff?
function IChartdiffsRepo:getChartdiffByChartkey(chartkey)
	return {}
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function IChartdiffsRepo:createChartdiff(chartdiff)
	return chartdiff
end

---@param chartdiff sea.Chartdiff
---@return sea.Chartdiff
function IChartdiffsRepo:updateChartdiff(chartdiff)
	return chartdiff
end

return IChartdiffsRepo
