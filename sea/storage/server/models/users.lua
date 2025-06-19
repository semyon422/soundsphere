local User = require("sea.access.User")
local Timezone = require("sea.activity.Timezone")

---@type rdb.ModelOptions
local users = {}

users.metatable = User

users.types = {
	activity_timezone = Timezone,
	is_banned = "boolean",
	is_restricted_info = "boolean",
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
