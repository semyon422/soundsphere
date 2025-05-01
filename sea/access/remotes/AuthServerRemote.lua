local class = require("class")
local valid = require("valid")
local table_util = require("table_util")
local UserInsecure = require("sea.access.UserInsecure")

---@class sea.AuthServerRemote: sea.IServerRemote
---@operator call: sea.AuthServerRemote
local AuthServerRemote = class()

---@param users sea.Users
---@param sessions web.Sessions
function AuthServerRemote:new(users, sessions)
	self.users = users
	self.sessions = sessions
end

---@return sea.Session?
function AuthServerRemote:checkSession()
	return self.users:checkSession(self.session)
end

---@return sea.Session?
function AuthServerRemote:updateSession()
	return self.users:updateSession(self.user, self.session)
end

local function clear_copy(src, dst)
	table_util.clear(dst)
	table_util.copy(src, dst)
end

---@param req_session sea.Session
---@return boolean?
function AuthServerRemote:loginSession(req_session)
	if not req_session.id then
		return
	end

	local session = self.users:checkSession(req_session)
	if not session then
		return
	end

	clear_copy(session, self.session)
	clear_copy(self.users:getUser(session.user_id), self.user)

	return true
end

---@param email string
---@param password string
---@return {session: sea.Session, user: sea.User, token: string}?
---@return string?
function AuthServerRemote:login(email, password)
	local user = UserInsecure()
	user.email = email
	user.password = password

	local ok, err = valid.format(user:validateLogin())
	if not ok then
		return nil, "login: " .. err
	end

	local su, err = self.users:login(self.user, self.ip, os.time(), user)
	if not su then
		return nil, err
	end

	clear_copy(su.session, self.session)
	clear_copy(su.user, self.user)

	return {
		session = su.session,
		user = su.user,
		token = self.sessions:encode(su.session),
	}
end

---@return true?
---@return string?
function AuthServerRemote:logout()
	return self.users:logout(self.user, self.session.id)
end

return AuthServerRemote
