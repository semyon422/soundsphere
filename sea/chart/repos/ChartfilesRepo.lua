local class = require("class")

---@class sea.ChartfilesRepo
---@operator call: sea.ChartfilesRepo
local ChartfilesRepo = class()

---@param models rdb.Models
function ChartfilesRepo:new(models)
	self.models = models
end

---@return sea.Chartfile[]
function ChartfilesRepo:getChartfiles()
	return self.models.chartfiles:select()
end

---@param hash string
---@return sea.Chartfile?
function ChartfilesRepo:getChartfileByHash(hash)
	return self.models.chartfiles:find({hash = assert(hash)})
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function ChartfilesRepo:createChartfile(chartfile)
	return self.models.chartfiles:create(chartfile)
end

---@param chartfile sea.Chartfile
---@return sea.Chartfile
function ChartfilesRepo:updateChartfile(chartfile)
	return self.models.chartfiles:update(chartfile, {id = assert(chartfile.id)})[1]
end

return ChartfilesRepo
