local class = require("class")
local table_util = require("table_util")
local Enum = require("rdb.Enum")

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

---@type {[string]: string[]}
Roles.below = {
	owner = {"admin"},
	admin = {"moderator", "verified", "donator", "user"},
}

---@type {[string]: string[]}
Roles.above = table_util.invert_graph(Roles.below)

-- is a -> b
---@param direction "below"|"above"
---@param a string
---@param b string
---@return true?
function Roles:belongs(direction, a, b)
	---@type string[]
	local list = self[direction][a]
	if not list then return end
	for _, role in ipairs(list) do
		if role == b or Roles:belongs(direction, role, b) then
			return true
		end
	end
end

assert(Roles:belongs("below", "admin", "verified"))
assert(Roles:belongs("above", "verified", "admin"))

---@param user_roles sea.UserRole[]
---@param role sea.Role
---@param exact boolean?
---@return boolean
function Roles:hasRole(user_roles, role, exact)
	for _, user_role in ipairs(user_roles) do
		local _role = user_role.role
		if _role == role or not exact and not user_role:isExpired() and self:belongs("below", _role, role) then
			return true
		end
	end
	return false
end

return Roles
