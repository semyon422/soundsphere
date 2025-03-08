local User = require("sea.access.User")

---@type rdb.ModelOptions
local users = {}

users.metatable = User

users.types = {
	is_banned = "boolean",
}

users.relations = {
	user_roles = {has_many = "user_roles", key = "user_id"},
}

return users
