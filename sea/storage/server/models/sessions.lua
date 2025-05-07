local Session = require("sea.access.Session")

---@type rdb.ModelOptions
local sessions = {}

sessions.metatable = Session

sessions.types = {
	active = "boolean",
}

---@param session sea.SessionInsecure
function sessions.from_db(session)
	session.ip = nil
end

return sessions
