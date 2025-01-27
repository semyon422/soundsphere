local class = require("class")
local Difftable = require("sea.difftables.Difftable")
local DifftableChart = require("sea.difftables.DifftableChart")
local DifftablesAccess = require("sea.difftables.access.DifftablesAccess")

---@class sea.Difftables
---@operator call: sea.Difftables
---@field id integer
local Difftables = class()

---@param difftables_repo sea.IDifftablesRepo
function Difftables:new(difftables_repo)
	self.difftables_repo = difftables_repo
	self.difftables_access = DifftablesAccess()
end

---@param user sea.User
---@param name string
---@return sea.Difftable?
---@return string?
function Difftables:create(user, name)
	local can, err = self.difftables_access:canManage(user)
	if not can then
		return nil, err
	end

	local difftable = Difftable()
	difftable.name = name

	return self.difftables_repo:createDifftable(difftable)
end

---@param user sea.User
---@param difftable_id integer
---@param chartdiff_id integer
---@param level number
---@return sea.DifftableChart?
---@return string?
function Difftables:setDifftableChart(user, difftable_id, chartdiff_id, level)
	local can, err = self.difftables_access:canManage(user)
	if not can then
		return nil, err
	end

	if not level then
		self.difftables_repo:deleteDifftableChart(difftable_id, chartdiff_id)
		return
	end

	local difftable_chart = self.difftables_repo:getDifftableChart(difftable_id, chartdiff_id)
	if difftable_chart then
		difftable_chart.level = level
		return self.difftables_repo:createDifftableChart(difftable_chart)
	end

	difftable_chart = DifftableChart()
	difftable_chart.difftable_id = difftable_id
	difftable_chart.chartdiff_id = chartdiff_id
	difftable_chart.level = level

	return self.difftables_repo:createDifftableChart(difftable_chart)
end

return Difftables
