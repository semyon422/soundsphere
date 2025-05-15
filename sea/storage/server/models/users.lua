local User = require("sea.access.User")

---@type rdb.ModelOptions
local users = {}

users.metatable = User

users.types = {
	is_banned = "boolean",
	enable_gradient = "boolean",
}

users.relations = {
	user_roles = {has_many = "user_roles", key = "user_id"},
}

---@param user sea.UserInsecure
function users.from_db(user)
	user.email = nil
	user.password = nil
end

return users
