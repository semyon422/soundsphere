local class = require("class")
local table_util = require("table_util")
local sql_util = require("rdb.sql_util")

---@class sphere.ChartdiffsRepo
---@operator call: sphere.ChartdiffsRepo
local ChartdiffsRepo = class()

---@param gdb sphere.GameDatabase
---@param diffcalc_fields string[]
function ChartdiffsRepo:new(gdb, diffcalc_fields)
	self.models = gdb.models
	self.diffcalc_fields = diffcalc_fields
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

function ChartdiffsRepo:deleteModifiedChartdiffs()
	self.models.chartdiffs:delete({
		"or",
		modifiers__ne = {},
		rate__ne = 1,
	})
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

function ChartdiffsRepo:getIncompleteChartdiffs()
	local conds = {}
	for _, field in ipairs(self.diffcalc_fields) do
		conds[field .. "__isnull"] = true
	end
	assert(next(conds))
	conds[1] = "or"
	return self.models.chartdiffs:select(conds)
end

---@param field string
function ChartdiffsRepo:resetDiffcalcField(field)
	assert(table_util.indexof(self.diffcalc_fields, field))
	self.models.chartdiffs:update({[field] = sql_util.NULL})
end

return ChartdiffsRepo
