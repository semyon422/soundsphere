local class = require("class")

---@class sphere.ChartmetasRepo
---@operator call: sphere.ChartmetasRepo
local ChartmetasRepo = class()

---@param gdb sphere.GameDatabase
function ChartmetasRepo:new(gdb)
	self.models = gdb.models
end

---@param chartmeta table
---@return table
function ChartmetasRepo:insertChartmeta(chartmeta)
	return self.models.chartmetas:create(chartmeta)
end

---@param chartmeta table
function ChartmetasRepo:updateChartmeta(chartmeta)
	self.models.chartmetas:update(chartmeta, {id = assert(chartmeta.id)})
end

---@param hash string
---@param index number
---@return table?
function ChartmetasRepo:selectChartmeta(hash, index)
	return self.models.chartmetas:find({hash = assert(hash), index = assert(index)})
end

---@param id number
---@return table?
function ChartmetasRepo:selectChartmetaById(id)
	return self.models.chartmetas:find({id = assert(id)})
end

---@return number
function ChartmetasRepo:countChartmetas()
	return self.models.chartmetas:count()
end

---@param conds table
function ChartmetasRepo:deleteChartmetas(conds)
	self.models.chartmetas:delete(conds)
end

return ChartmetasRepo
