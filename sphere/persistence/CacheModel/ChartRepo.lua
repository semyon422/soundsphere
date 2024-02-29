local class = require("class")

---@class sphere.ChartRepo
---@operator call: sphere.ChartRepo
local ChartRepo = class()

---@param gdb sphere.GameDatabase
function ChartRepo:new(gdb)
	self.models = gdb.models
end

--------------------------------------------------------------------------------

---@param chartmeta table
---@return table
function ChartRepo:insertChartmeta(chartmeta)
	return self.models.chartmetas:create(chartmeta)
end

---@param chartmeta table
function ChartRepo:updateChartmeta(chartmeta)
	self.models.chartmetas:update(chartmeta, {id = assert(chartmeta.id)})
end

---@param hash string
---@param index number
---@return table?
function ChartRepo:selectChartmeta(hash, index)
	return self.models.chartmetas:find({hash = assert(hash), index = assert(index)})
end

---@param id number
---@return table?
function ChartRepo:selectChartmetaById(id)
	return self.models.chartmetas:find({id = assert(id)})
end

---@return number
function ChartRepo:countChartmetas()
	return self.models.chartmetas:count()
end

---@param conds table
function ChartRepo:deleteChartmetas(conds)
	self.models.chartmetas:delete(conds)
end

--------------------------------------------------------------------------------

---@param chartdiff table
---@return table
function ChartRepo:insertChartdiff(chartdiff)
	return self.models.chartdiffs:create(chartdiff)
end

---@param chartdiff table
---@return table?
function ChartRepo:updateChartdiff(chartdiff)
	return self.models.chartdiffs:update(chartdiff, {id = assert(chartdiff.id)})[1]
end

---@param hash string
---@param index number
---@return table?
function ChartRepo:selectDefaultChartdiff(hash, index)
	return self.models.chartdiffs:find({
		hash = assert(hash),
		index = assert(index),
		modifiers = "",
		rate = 1,
	})
end

---@param chartdiff table
---@return table?
function ChartRepo:selectChartdiff(chartdiff)
	return self.models.chartdiffs:find({
		hash = assert(chartdiff.hash),
		index = assert(chartdiff.index),
		modifiers = assert(chartdiff.modifiers),
		rate = assert(chartdiff.rate),
	})
end

---@param id number
---@return table?
function ChartRepo:selectChartdiffById(id)
	return self.models.chartdiffs:find({id = assert(id)})
end

---@return number
function ChartRepo:countChartdiffs()
	return self.models.chartdiffs:count()
end

return ChartRepo
