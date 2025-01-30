local class = require("class")
local TestModel = require("rdb.TestModel")

---@class sea.FakeDifftablesRepo
---@operator call: sea.FakeDifftablesRepo
local FakeDifftablesRepo = class()

function FakeDifftablesRepo:new()
	self.difftables = TestModel()
	self.difftable_charts = TestModel()
end

---@return sea.Difftable[]
function FakeDifftablesRepo:getDifftables()
	return self.difftables:select()
end

---@param id integer
---@return sea.Difftable?
function FakeDifftablesRepo:getDifftable(id)
	return self.difftables:find({id = id})
end

---@param difftable sea.Difftable
---@return sea.Difftable
function FakeDifftablesRepo:createDifftable(difftable)
	return self.difftables:create(difftable)
end

---@param difftable sea.Difftable
---@return sea.Difftable
function FakeDifftablesRepo:updateDifftable(difftable)
	return self.difftables:update(difftable, {id = difftable.id})[1]
end

--------------------------------------------------------------------------------

---@param difftable_id integer
---@param chartdiff_id integer
---@return sea.DifftableChart?
function FakeDifftablesRepo:getDifftableChart(difftable_id, chartdiff_id)
	return self.difftable_charts:find({difftable_id = difftable_id, chartdiff_id = chartdiff_id})
end

---@param difftable_chart sea.DifftableChart
---@return sea.DifftableChart
function FakeDifftablesRepo:createDifftableChart(difftable_chart)
	return self.difftable_charts:create(difftable_chart)
end

---@param difftable_chart sea.DifftableChart
---@return sea.DifftableChart
function FakeDifftablesRepo:updateDifftableChart(difftable_chart)
	return self.difftable_charts:update(difftable_chart, {id = difftable_chart.id})[1]
end

---@param difftable_id integer
---@param chartdiff_id integer
function FakeDifftablesRepo:deleteDifftableChart(difftable_id, chartdiff_id)
	return self.difftable_charts:remove({difftable_id = difftable_id, chartdiff_id = chartdiff_id})[1]
end

return FakeDifftablesRepo
