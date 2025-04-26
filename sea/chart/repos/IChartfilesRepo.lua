local class = require("class")

---@class sea.IChartfilesRepo
---@operator call: sea.IChartfilesRepo
local IChartfilesRepo = class()

---@return sea.Chartfile[]
function IChartfilesRepo:getChartfiles()
	return {}
end

---@param hash string
---@return sea.Chartfile?
function IChartfilesRepo:getChartfileByHash(hash)
	return {}
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function IChartfilesRepo:createChartfile(chartfile)
	return chartfile
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function IChartfilesRepo:updateChartfile(chartfile)
	return chartfile
end

return IChartfilesRepo
