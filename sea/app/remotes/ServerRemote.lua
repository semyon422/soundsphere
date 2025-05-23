local class = require("class")
local SubmissionServerRemote = require("sea.chart.remotes.SubmissionServerRemote")
local AuthServerRemote = require("sea.access.remotes.AuthServerRemote")

---@class sea.ServerRemote: sea.IServerRemote
---@operator call: sea.ServerRemote
local ServerRemote = class()

---@param domain sea.Domain
---@param sessions web.Sessions
function ServerRemote:new(domain, sessions)
	self.auth = AuthServerRemote(domain.users, sessions)
	self.submission = SubmissionServerRemote(domain)
end

---@return sea.User
function ServerRemote:getUser()
	return self.user
end

---@return sea.Session
function ServerRemote:getSession()
	return self.session
end

---@param msg string
---@return string
function ServerRemote:ping(msg)
	return msg .. "world" .. self.user.id
end

return ServerRemote
