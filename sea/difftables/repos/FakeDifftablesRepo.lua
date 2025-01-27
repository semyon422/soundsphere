local class = require("class")
local table_util = require("table_util")

---@class sea.FakeDifftablesRepo
---@operator call: sea.FakeDifftablesRepo
local FakeDifftablesRepo = class()

function FakeDifftablesRepo:new()
	---@type sea.Difftable[]
	self.difftables = {}
	---@type sea.DifftableChart[]
	self.difftable_charts = {}
end

---@return sea.Difftable[]
function FakeDifftablesRepo:getDifftables()
	return self.difftables
end

---@param id integer
---@return sea.Difftable?
function FakeDifftablesRepo:getDifftable(id)
	return table_util.value_by_field(self.difftables, "id", id)
end

---@param difftable sea.Difftable
---@return sea.Difftable
function FakeDifftablesRepo:createDifftable(difftable)
	table.insert(self.difftables, difftable)
	difftable.id = #self.difftables
	return difftable
end

---@param difftable sea.Difftable
---@return sea.Difftable
function FakeDifftablesRepo:updateDifftable(difftable)
	local _difftable_chart = table_util.value_by_field(self.difftables, "id", difftable.id)
	table_util.copy(difftable, _difftable_chart)
	return difftable
end

--------------------------------------------------------------------------------

---@param difftable_id integer
---@param chartdiff_id integer
---@return sea.DifftableChart?
function FakeDifftablesRepo:getDifftableChart(difftable_id, chartdiff_id)
	for _, difftable_chart in ipairs(self.difftable_charts) do
		if difftable_chart.difftable_id == difftable_id and difftable_chart.chartdiff_id == chartdiff_id then
			return difftable_chart
		end
	end
end

---@param difftable_chart sea.DifftableChart
---@return sea.DifftableChart
function FakeDifftablesRepo:createDifftableChart(difftable_chart)
	table.insert(self.difftable_charts, difftable_chart)
	difftable_chart.id = #self.difftable_charts
	return difftable_chart
end

---@param difftable_chart sea.DifftableChart
---@return sea.DifftableChart
function FakeDifftablesRepo:updateDifftableChart(difftable_chart)
	local _difftable_chart = table_util.value_by_field(self.difftables, "id", difftable_chart.id)
	table_util.copy(difftable_chart, _difftable_chart)
	return difftable_chart
end

---@param difftable_id integer
---@param chartdiff_id integer
function FakeDifftablesRepo:deleteDifftableChart(difftable_id, chartdiff_id)
	for i, difftable_chart in ipairs(self.difftable_charts) do
		if difftable_chart.difftable_id == difftable_id and difftable_chart.chartdiff_id == chartdiff_id then
			table.remove(self.difftable_charts, i)
			return
		end
	end
end

return FakeDifftablesRepo
