local class = require("class")
local Difftable = require("sea.difftables.Difftable")
local DifftableChartmeta = require("sea.difftables.DifftableChartmeta")
local DifftablesAccess = require("sea.difftables.access.DifftablesAccess")

---@class sea.Difftables
---@operator call: sea.Difftables
---@field id integer
local Difftables = class()

---@param difftables_repo sea.DifftablesRepo
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
---@param dt_values sea.Difftable
---@return sea.Difftable?
---@return string?
function Difftables:create(user, dt_values)
	local can, err = self.difftables_access:canManage(user, os.time())
	if not can then
		return nil, err
	end

	local dt = self.difftables_repo:getDifftableByName(dt_values.name)
	if dt then
		return nil, "name taken"
	end

	dt = self.difftables_repo:getDifftableByTag(dt_values.tag)
	if dt then
		return nil, "tag taken"
	end

	dt = Difftable()
	dt.name = dt_values.name
	dt.description = dt_values.description
	dt.symbol = dt_values.symbol
	dt.tag = dt_values.tag
	dt.created_at = os.time()

	return self.difftables_repo:createDifftable(dt)
end

---@param user sea.User
---@param id integer
---@param dt_values sea.Difftable
---@return sea.Difftable?
---@return string?
function Difftables:update(user, id, dt_values)
	local can, err = self.difftables_access:canManage(user, os.time())
	if not can then
		return nil, err
	end

	local dt = self.difftables_repo:getDifftableByName(dt_values.name)
	if dt and dt.id ~= id then
		return nil, "name taken"
	end

	dt = self.difftables_repo:getDifftableByTag(dt_values.tag)
	if dt and dt.id ~= id then
		return nil, "tag taken"
	end

	dt = dt or self.difftables_repo:getDifftable(id)

	if not dt then
		return nil, "not found"
	end

	dt.name = dt_values.name
	dt.description = dt_values.description
	dt.symbol = dt_values.symbol
	dt.tag = dt_values.tag

	self.difftables_repo:updateDifftableFull(dt)

	return dt
end

---@param user sea.User
---@param id integer
---@return true?
---@return string?
function Difftables:delete(user, id)
	local can, err = self.difftables_access:canManage(user, os.time())
	if not can then
		return nil, err
	end

	self.difftables_repo:deleteDifftable(id)

	return true
end

---@param user sea.User
---@param time integer
---@param difftable_id integer
---@param since integer?
---@param include_deleted boolean?
---@param limit integer?
---@return sea.DifftableChartmeta[]?
---@return string?
function Difftables:getDifftableChartmetas(user, time, difftable_id, include_deleted, since, limit)
	if user:isAnon() then
		return nil, "not allowed"
	end

	return self.difftables_repo:getDifftableChartmetas(difftable_id, include_deleted, since, limit)
end

---@param user sea.User
---@param time integer
---@param difftable_id integer
---@param since integer?
---@param include_deleted boolean?
---@return sea.DifftableChartmeta[]?
---@return string?
function Difftables:getDifftableChartmetasFull(user, time, difftable_id, include_deleted, since)
	if user:isAnon() then
		return nil, "not allowed"
	end

	return self.difftables_repo:getDifftableChartmetasFull(difftable_id, include_deleted, since)
end

---@param user sea.User
---@param time integer
---@param difftable_id integer
---@param hash string
---@param index integer
---@param level number?
---@return sea.DifftableChartmeta?
---@return string?
function Difftables:setDifftableChartmeta(user, time, difftable_id, hash, index, level)
	local can, err = self.difftables_access:canManage(user, time)
	if not can then
		return nil, err
	end

	local dt_cm = self.difftables_repo:getDifftableChartmeta(difftable_id, hash, index)
	if dt_cm then
		dt_cm.level = level or dt_cm.level
		dt_cm.is_deleted = false
		dt_cm.updated_at = time
		return self.difftables_repo:updateDifftableChartmeta(dt_cm)
	end

	dt_cm = DifftableChartmeta()
	dt_cm.user_id = user.id
	dt_cm.difftable_id = difftable_id
	dt_cm.hash = hash
	dt_cm.index = index
	dt_cm.level = level or 0
	dt_cm.is_deleted = false
	dt_cm.created_at = time
	dt_cm.updated_at = time

	return self.difftables_repo:createDifftableChartmeta(dt_cm)
end

---@param user sea.User
---@param time integer
---@param difftable_id integer
---@param hash string
---@param index integer
---@return sea.DifftableChartmeta?
---@return string?
function Difftables:deleteDifftableChartmeta(user, time, difftable_id, hash, index)
	local can, err = self.difftables_access:canManage(user, time)
	if not can then
		return nil, err
	end

	local dt_cm = self.difftables_repo:getDifftableChartmeta(difftable_id, hash, index)
	if not dt_cm then
		return nil, "not found"
	end

	dt_cm.is_deleted = true
	dt_cm.updated_at = time

	return self.difftables_repo:updateDifftableChartmeta(dt_cm)
end

return Difftables
