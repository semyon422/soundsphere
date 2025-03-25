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

---@param name string
---@return sea.Difftable?
function IDifftablesRepo:getDifftableByName(name)
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

---@param id integer
---@return sea.Difftable?
function IDifftablesRepo:deleteDifftable(id)
	return {}
end

--------------------------------------------------------------------------------

---@param difftable_id integer
---@param hash string
---@param index integer
---@return sea.DifftableChartmeta?
function IDifftablesRepo:getDifftableChartmeta(difftable_id, hash, index)
	return {}
end

---@param difftable_chartmeta sea.DifftableChartmeta
---@return sea.DifftableChartmeta
function IDifftablesRepo:createDifftableChartmeta(difftable_chartmeta)
	return {}
end

---@param difftable_chartmeta sea.DifftableChartmeta
---@return sea.DifftableChartmeta
function IDifftablesRepo:updateDifftableChartmeta(difftable_chartmeta)
	return {}
end

---@param difftable_id integer
---@param hash string
---@param index integer
function IDifftablesRepo:deleteDifftableChartmeta(difftable_id, hash, index)
end

return IDifftablesRepo
