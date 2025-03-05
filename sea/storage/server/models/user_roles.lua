local UserRole = require("sea.access.UserRole")
local Roles = require("sea.access.Roles")

---@type rdb.ModelOptions
local user_roles = {}

user_roles.metatable = UserRole

user_roles.types = {
	role = Roles.enum,
}

return user_roles
