local ip = require("web.ip")

---@class sea.old.Session
---@field id integer
---@field user_id integer
---@field active boolean
---@field ip string
---@field created_at integer
---@field updated_at integer

---@type rdb.ModelOptions
local sessions = {}

sessions.types = {
	active = "boolean",
	ip = ip,
}

sessions.relations = {
	user = {belongs_to = "users", key = "user_id"},
}

return sessions
