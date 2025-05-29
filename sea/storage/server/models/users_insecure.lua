local UserInsecure = require("sea.access.UserInsecure")

---@type rdb.ModelOptions
local users_insecure = {}

users_insecure.table_name = "users"

users_insecure.metatable = UserInsecure

users_insecure.types = {
	is_banned = "boolean",
	enable_gradient = "boolean",
}

users_insecure.relations = {
	user_roles = {has_many = "user_roles", key = "user_id"},
}

return users_insecure
