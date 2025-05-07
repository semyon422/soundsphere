local SessionInsecure = require("sea.access.SessionInsecure")

---@type rdb.ModelOptions
local sessions_insecure = {}

sessions_insecure.table_name = "sessions"

sessions_insecure.metatable = SessionInsecure

sessions_insecure.types = {
	active = "boolean",
}

return sessions_insecure
