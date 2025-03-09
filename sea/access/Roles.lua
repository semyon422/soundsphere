local class = require("class")
local table_util = require("table_util")
local Enum = require("rdb.Enum")
local UserRole = require("sea.access.UserRole")

---@class sea.Roles
---@operator call: sea.Roles
local Roles = class()

---@enum (key) sea.Role
local Role = {
	user = 0,
	owner = 1,
	admin = 2,
	moderator = 3,
	verified = 4,
	donator = 5,
}

Roles.enum = Enum(Role)
Roles.list = Roles.enum:list()

---@type {[sea.Role]: sea.Role[]}
Roles.below = {
	owner = {"admin"},
	admin = {"moderator", "verified", "donator", "user"},
}

---@type {[sea.Role]: sea.Role[]}
Roles.above = table_util.invert_graph(Roles.below)

-- is a -> b
---@param direction "below"|"above"
---@param a sea.Role?
---@param b sea.Role?
---@return boolean?
function Roles:belongs(direction, a, b)
	if a and not b then
		return true
	end
	if not a and b then
		return false
	end
	---@type sea.Role[]
	local list = self[direction][a]
	if not list then return end
	for _, role in ipairs(list) do
		if role == b or Roles:belongs(direction, role, b) then
			return true
		end
	end
	return false
end

assert(Roles:belongs("below", "admin", "verified"))
assert(Roles:belongs("below", "admin", nil))
assert(not Roles:belongs("below", nil, "admin"))
assert(Roles:belongs("above", "verified", "admin"))

---@param user_roles sea.UserRole[] active user roles
---@param role sea.Role?
---@param exact boolean?
---@return boolean
function Roles:hasRole(user_roles, role, exact)
	for _, user_role in ipairs(user_roles) do
		local _role = user_role.role
		if _role == role or not exact and self:belongs("below", _role, role) then
			return true
		end
	end
	return false
end

---@param user_roles sea.UserRole[]
---@return sea.Role?
function Roles:getHighestRole(user_roles)
	---@type sea.Role?
	local role
	for _, user_role in ipairs(user_roles) do
		local _role = user_role.role
		if not role or self:belongs("below", _role, role) then
			role = _role
		end
	end
	return role
end

--- Returns true if 1st is "above" 2nd
---@param user_roles_a sea.UserRole[]
---@param user_roles_b sea.UserRole[]
---@return true?
function Roles:compare(user_roles_a, user_roles_b)
	local a = self:getHighestRole(user_roles_a)
	local b = self:getHighestRole(user_roles_b)
	return self:belongs("below", a, b)
end

assert(Roles:compare({UserRole("admin", 0)}, {UserRole("user", 0)}))
assert(Roles:compare({UserRole("admin", 0)}, {}))
assert(not Roles:compare({}, {UserRole("admin", 0)}))
assert(not Roles:compare({}, {}))
assert(not Roles:compare({UserRole("moderator", 0)}, {UserRole("donator", 0)}))

---@param user_roles sea.UserRole[]
---@param time integer
---@return sea.UserRole[]
function Roles:filterActive(user_roles, time)
	---@type sea.UserRole[]
	local _user_roles = {}
	for _, user_role in ipairs(user_roles) do
		if not user_role:isExpired(time) then
			table.insert(_user_roles, user_role)
		end
	end
	return _user_roles
end

return Roles
