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

---@param roles sea.Role[]
---@param role sea.Role?
---@param exact boolean?
---@return boolean
function Roles:hasRole(roles, role, exact)
	for _, _role in ipairs(roles) do
		if _role == role or not exact and self:belongs("below", _role, role) then
			return true
		end
	end
	return false
end

--- Returns true if 1st is "above" 2nd
--- Isn't optimal but ok
---@param roles_a sea.Role[]
---@param roles_b sea.Role[]
---@return true?
function Roles:compare(roles_a, roles_b)
	for _, role_a in ipairs(roles_a) do
		local above = true
		for _, role_b in ipairs(roles_b) do
			above = above and self:belongs("below", role_a, role_b)
		end
		if above then
			return true
		end
	end
end

assert(Roles:compare({"admin"}, {"user"}))
assert(Roles:compare({"admin"}, {}))
assert(not Roles:compare({"user"}, {"user"}))
assert(not Roles:compare({"user"}, {"verified"}))
assert(not Roles:compare({}, {"admin"}))
assert(not Roles:compare({}, {}))
assert(not Roles:compare({"moderator"}, {"donator"}))

---@param user_roles sea.UserRole[]
---@param time integer
---@return sea.Role[]
function Roles:filter(user_roles, time)
	---@type sea.Role[]
	local roles = {}
	for _, user_role in ipairs(user_roles) do
		if not user_role:isExpired(time) then
			table.insert(roles, user_role.role)
		end
	end
	return roles
end

return Roles
