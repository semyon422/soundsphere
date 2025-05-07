local ip = require("web.ip")

---@class sea.old.UserLocation
---@field id integer
---@field user_id integer
---@field ip string
---@field created_at integer
---@field updated_at integer
---@field is_register boolean
---@field sessions_count integer

---@type rdb.ModelOptions
local user_locations = {}

user_locations.types = {
	is_register = "boolean",
	ip = ip,
}

user_locations.relations = {
	user = {belongs_to = "users", key = "user_id"},
}

return user_locations
