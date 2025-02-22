local class = require("class")
local TestModel = require("rdb.TestModel")

---@class sea.FakeDifftablesRepo
---@operator call: sea.FakeDifftablesRepo
local FakeDifftablesRepo = class()

function FakeDifftablesRepo:new()
	self.difftables = TestModel()
	self.difftable_chartmetas = TestModel()
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
---@param hash string
---@param index integer
---@return sea.DifftableChartmeta?
function FakeDifftablesRepo:getDifftableChartmeta(difftable_id, hash, index)
	return self.difftable_chartmetas:find({
		difftable_id = difftable_id,
		hash = hash,
		index = index,
	})
end

---@param difftable_chartmeta sea.DifftableChartmeta
---@return sea.DifftableChartmeta
function FakeDifftablesRepo:createDifftableChartmeta(difftable_chartmeta)
	return self.difftable_chartmetas:create(difftable_chartmeta)
end

---@param difftable_chartmeta sea.DifftableChartmeta
---@return sea.DifftableChartmeta
function FakeDifftablesRepo:updateDifftableChartmeta(difftable_chartmeta)
	return self.difftable_chartmetas:update(difftable_chartmeta, {id = difftable_chartmeta.id})[1]
end

---@param difftable_id integer
---@param hash string
---@param index integer
function FakeDifftablesRepo:deleteDifftableChartmeta(difftable_id, hash, index)
	self.difftable_chartmetas:remove({
		difftable_id = difftable_id,
		hash = hash,
		index = index,
	})
end

return FakeDifftablesRepo
