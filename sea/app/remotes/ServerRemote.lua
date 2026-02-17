local class = require("class")
local SubmissionServerRemote = require("sea.chart.remotes.SubmissionServerRemote")
local AuthServerRemote = require("sea.access.remotes.AuthServerRemote")
local LeaderboardsServerRemote = require("sea.leaderboards.remotes.LeaderboardsServerRemote")
local DifftablesServerRemote = require("sea.difftables.remotes.DifftablesServerRemote")

---@class sea.ServerRemote: sea.IServerRemote
---@operator call: sea.ServerRemote
local ServerRemote = class()

---@param domain sea.Domain
---@param sessions web.Sessions
function ServerRemote:new(domain, sessions)
	self.auth = AuthServerRemote(domain.users, sessions, domain.user_connections)
	self.submission = SubmissionServerRemote(domain.chartplay_submission, domain.chartplays)
	self.leaderboards = LeaderboardsServerRemote(domain.leaderboards)
	self.difftables = DifftablesServerRemote(domain.difftables)
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
