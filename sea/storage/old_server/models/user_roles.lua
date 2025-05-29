local Roles = require("sea.storage.old_server.Roles")

---@class sea.old.UserRole
---@field id integer
---@field user_id integer
---@field role sea.old.Roles
---@field expires_at integer
---@field total_time integer

---@type rdb.ModelOptions
local user_roles = {}

user_roles.types = {
	role = Roles,
}

user_roles.relations = {
	user = {belongs_to = "users", key = "user_id"},
}

return user_roles
