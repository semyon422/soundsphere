local Session = require("sea.access.Session")

---@class sea.SessionInsecure: sea.Session
---@operator call: sea.SessionInsecure
---@field ip string
local SessionInsecure = Session + {}

---@return sea.Session
function SessionInsecure:hideIp()
	self.ip = nil
	return setmetatable(self, Session)
end

return SessionInsecure
