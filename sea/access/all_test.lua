local CustomAccess = require("sea.access.CustomAccess")
local User = require("sea.access.User")
local UserRole = require("sea.access.UserRole")

local test = {}

---@param t testing.T
function test.owner_role_bypass(t)
	local access = {}
	function access:canUpdate(user, obj) return user.id == obj.owner_id end

	local custom_access = CustomAccess(access, "qwe")

	local user = User()
	user.id = 1

	local obj = {owner_id = 1}

	t:assert(access:canUpdate(user, obj))
	t:assert(custom_access:canUpdate(user, obj))

	obj.owner_id = 2

	t:assert(not access:canUpdate(user, obj))
	t:assert(not custom_access:canUpdate(user, obj))

	local user_role = UserRole()
	user_role.role = "owner"
	table.insert(user.user_roles, user_role)

	t:assert(not access:canUpdate(user, obj))
	t:assert(custom_access:canUpdate(user, obj))
end

---@param t testing.T
function test.has_role(t)
	local user = User()

	t:assert(not user:hasRole("owner"))

	local user_role = UserRole()
	user_role.role = "admin"
	table.insert(user.user_roles, user_role)

	t:assert(not user:hasRole("owner"))

	user_role = UserRole()
	user_role.role = "owner"
	table.insert(user.user_roles, user_role)

	t:assert(user:hasRole("owner"))
end

return test
