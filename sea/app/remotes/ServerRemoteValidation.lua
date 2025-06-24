local class = require("class")
local User = require("sea.access.User")
local Session = require("sea.access.Session")
local SubmissionServerRemoteValidation = require("sea.chart.remotes.SubmissionServerRemoteValidation")
local DifftablesServerRemoteValidation = require("sea.difftables.remotes.DifftablesServerRemoteValidation")

---@class sea.ServerRemoteValidation: sea.ServerRemote
---@operator call: sea.ServerRemoteValidation
local ServerRemoteValidation = class()

---@param remote sea.ServerRemote
function ServerRemoteValidation:new(remote)
	self.remote = remote
	self.auth = remote.auth
	self.submission = SubmissionServerRemoteValidation(remote.submission)
	self.leaderboards = remote.leaderboards
	self.difftables = DifftablesServerRemoteValidation(remote.difftables)
end

---@return sea.User
function ServerRemoteValidation:getUser()
	local user = self.remote:getUser()
	assert(type(user) == "table")
	return setmetatable(user, User)
end

---@return sea.Session
function ServerRemoteValidation:getSession()
	local session = self.remote:getSession()
	assert(type(session) == "table")
	return setmetatable(session, Session)
end

---@param msg string
---@return string
function ServerRemoteValidation:ping(msg)
	assert(type(msg) == "string")
	local res = self.remote:ping(msg)
	assert(type(res) == "string")
	return res
end

return ServerRemoteValidation
