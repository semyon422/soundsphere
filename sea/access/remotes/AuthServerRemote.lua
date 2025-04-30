local class = require("class")

---@class sea.AuthServerRemote: sea.IServerRemote
---@operator call: sea.AuthServerRemote
local AuthServerRemote = class()

---@param users sea.Users
function AuthServerRemote:new(users)
	self.users = users
end

---@return sea.Session?
function AuthServerRemote:checkSession()
	return self.users:checkSession(self.session)
end

---@return sea.Session?
function AuthServerRemote:updateSession()
	return self.users:updateSession(self.user, self.session)
end

return AuthServerRemote
