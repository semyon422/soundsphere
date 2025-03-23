local class = require("class")
local Difftable = require("sea.difftables.Difftable")
local DifftableChartmeta = require("sea.difftables.DifftableChartmeta")
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

---@return sea.Difftable[]
function Difftables:getDifftables()
	return self.difftables_repo:getDifftables()
end

---@param id integer?
---@return sea.Difftable?
function Difftables:getDifftable(id)
	if not id then
		return
	end
	return self.difftables_repo:getDifftable(id)
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
---@param hash string
---@param index integer
---@param level number?
---@return sea.DifftableChartmeta?
---@return string?
function Difftables:setDifftableChartmeta(user, difftable_id, hash, index, level)
	local can, err = self.difftables_access:canManage(user)
	if not can then
		return nil, err
	end

	if not level then
		self.difftables_repo:deleteDifftableChartmeta(difftable_id, hash, index)
		return
	end

	local dt_cm = self.difftables_repo:getDifftableChartmeta(difftable_id, hash, index)
	if dt_cm then
		dt_cm.level = level
		return self.difftables_repo:updateDifftableChartmeta(dt_cm)
	end

	dt_cm = DifftableChartmeta()
	dt_cm.difftable_id = difftable_id
	dt_cm.hash = hash
	dt_cm.index = index
	dt_cm.level = level

	return self.difftables_repo:createDifftableChartmeta(dt_cm)
end

return Difftables
