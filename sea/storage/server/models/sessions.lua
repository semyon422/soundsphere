local Session = require("sea.access.Session")

---@type rdb.ModelOptions
local sessions = {}

sessions.metatable = Session

sessions.types = {
	active = "boolean",
}

return sessions
