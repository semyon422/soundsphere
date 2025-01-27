local class = require("class")

---@class sea.IDifftablesRepo
---@operator call: sea.IDifftablesRepo
local IDifftablesRepo = class()

---@return sea.Difftable[]
function IDifftablesRepo:getDifftables()
	return {}
end

---@param id integer
---@return sea.Difftable?
function IDifftablesRepo:getDifftable(id)
	return {}
end

---@param difftable sea.Difftable
---@return sea.Difftable
function IDifftablesRepo:createDifftable(difftable)
	return difftable
end

---@param difftable sea.Difftable
---@return sea.Difftable
function IDifftablesRepo:updateDifftable(difftable)
	return difftable
end

--------------------------------------------------------------------------------

---@param difftable_id integer
---@param chartdiff_id integer
---@return sea.DifftableChart?
function IDifftablesRepo:getDifftableChart(difftable_id, chartdiff_id)
	return {}
end

---@param difftable_chart sea.DifftableChart
---@return sea.DifftableChart
function IDifftablesRepo:createDifftableChart(difftable_chart)
	return {}
end

---@param difftable_chart sea.DifftableChart
---@return sea.DifftableChart
function IDifftablesRepo:updateDifftableChart(difftable_chart)
	return {}
end

---@param difftable_id integer
---@param chartdiff_id integer
function IDifftablesRepo:deleteDifftableChart(difftable_id, chartdiff_id)
end

return IDifftablesRepo
