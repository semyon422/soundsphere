local class = require("class")

---@class sea.DifftablesRepo
---@operator call: sea.DifftablesRepo
local DifftablesRepo = class()

---@param models rdb.Models
function DifftablesRepo:new(models)
	self.models = models
end

---@return sea.Difftable[]
function DifftablesRepo:getDifftables()
	return self.models.difftables:select()
end

---@param id integer
---@return sea.Difftable?
function DifftablesRepo:getDifftable(id)
	return self.models.difftables:find({id = assert(id)})
end

---@param name string
---@return sea.Difftable?
function DifftablesRepo:getDifftableByName(name)
	return self.models.difftables:find({name = assert(name)})
end

---@param difftable sea.Difftable
---@return sea.Difftable
function DifftablesRepo:createDifftable(difftable)
	return self.models.difftables:create(difftable)
end

---@param difftable sea.Difftable
---@return sea.Difftable
function DifftablesRepo:updateDifftable(difftable)
	return self.models.difftables:update(difftable, {id = assert(difftable.id)})[1]
end

---@param id integer
---@return sea.Difftable?
function DifftablesRepo:deleteDifftable(id)
	return self.models.difftables:delete({id = assert(id)})[1]
end

--------------------------------------------------------------------------------

---@param difftable_id integer
---@param hash string
---@param index integer
---@return sea.DifftableChartmeta?
function DifftablesRepo:getDifftableChartmeta(difftable_id, hash, index)
	return self.models.difftable_chartmetas:find({
		difftable_id = assert(difftable_id),
		hash = assert(hash),
		index = assert(index),
	})
end

---@param difftable_chartmeta sea.DifftableChartmeta
---@return sea.DifftableChartmeta
function DifftablesRepo:createDifftableChartmeta(difftable_chartmeta)
	return self.models.difftable_chartmetas:create(difftable_chartmeta)
end

---@param difftable_chartmeta sea.DifftableChartmeta
---@return sea.DifftableChartmeta
function DifftablesRepo:updateDifftableChartmeta(difftable_chartmeta)
	return self.models.difftable_chartmetas:update(difftable_chartmeta, {id = assert(difftable_chartmeta.id)})[1]
end

---@param difftable_id integer
---@param hash string
---@param index integer
function DifftablesRepo:deleteDifftableChartmeta(difftable_id, hash, index)
	return self.models.difftable_chartmetas:delete({
		difftable_id = assert(difftable_id),
		hash = assert(hash),
		index = assert(index),
	})
end

return DifftablesRepo
