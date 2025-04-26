local class = require("class")

---@class sphere.ChartmetasRepo
---@operator call: sphere.ChartmetasRepo
local ChartmetasRepo = class()

---@param gdb sphere.GameDatabase
function ChartmetasRepo:new(gdb)
	self.models = gdb.models
end

---@param chartmeta table
---@return sea.Chartmeta
function ChartmetasRepo:insertChartmeta(chartmeta)
	return self.models.chartmetas:create(chartmeta)
end

---@param chartmeta table
function ChartmetasRepo:updateChartmeta(chartmeta)
	self.models.chartmetas:update(chartmeta, {id = assert(chartmeta.id)})
end

---@param hash string
---@param index integer
---@return sea.Chartmeta?
function ChartmetasRepo:selectChartmeta(hash, index)
	return self.models.chartmetas:find({hash = assert(hash), index = assert(index)})
end

---@param id integer
---@return sea.Chartmeta?
function ChartmetasRepo:selectChartmetaById(id)
	return self.models.chartmetas:find({id = assert(id)})
end

---@return integer
function ChartmetasRepo:countChartmetas()
	return self.models.chartmetas:count()
end

---@param conds table
function ChartmetasRepo:deleteChartmetas(conds)
	self.models.chartmetas:delete(conds)
end

---@return sea.Chartmeta[]
function ChartmetasRepo:getChartmetasWithMissingChartdiffs()
	return self.models.chartmetas_diffs_missing:select()
end

return ChartmetasRepo
