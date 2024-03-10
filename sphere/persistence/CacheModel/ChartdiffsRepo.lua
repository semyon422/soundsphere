local class = require("class")

---@class sphere.ChartdiffsRepo
---@operator call: sphere.ChartdiffsRepo
local ChartdiffsRepo = class()

---@param gdb sphere.GameDatabase
function ChartdiffsRepo:new(gdb)
	self.models = gdb.models
end

---@param chartdiff table
---@return table
function ChartdiffsRepo:insertChartdiff(chartdiff)
	return self.models.chartdiffs:create(chartdiff)
end

---@param chartdiff table
---@return table?
function ChartdiffsRepo:updateChartdiff(chartdiff)
	return self.models.chartdiffs:update(chartdiff, {id = assert(chartdiff.id)})[1]
end

---@param hash string
---@param index number
---@return table?
function ChartdiffsRepo:selectDefaultChartdiff(hash, index)
	return self.models.chartdiffs:find({
		hash = assert(hash),
		index = assert(index),
		modifiers = {},
		rate = 1,
	})
end

---@param chartdiff table
---@return table?
function ChartdiffsRepo:selectChartdiff(chartdiff)
	return self.models.chartdiffs:find({
		hash = assert(chartdiff.hash),
		index = assert(chartdiff.index),
		modifiers = chartdiff.modifiers or {},
		rate = chartdiff.rate or 1,
	})
end

---@param id number
---@return table?
function ChartdiffsRepo:selectChartdiffById(id)
	return self.models.chartdiffs:find({id = assert(id)})
end

---@return number
function ChartdiffsRepo:countChartdiffs()
	return self.models.chartdiffs:count()
end

---@param conds table
function ChartdiffsRepo:deleteChartdiffs(conds)
	self.models.chartdiffs:delete(conds)
end

---@param chartdiff table
function ChartdiffsRepo:createUpdateChartdiff(chartdiff)
	local _chartdiff = self:selectChartdiff(chartdiff)
	if not _chartdiff then
		return self:insertChartdiff(chartdiff)
	end
	chartdiff.id = _chartdiff.id
	return self:updateChartdiff(chartdiff)
end

return ChartdiffsRepo
