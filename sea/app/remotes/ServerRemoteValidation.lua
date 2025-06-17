local class = require("class")
local SubmissionServerRemoteValidation = require("sea.chart.remotes.SubmissionServerRemoteValidation")

---@class sea.ServerRemoteValidation: sea.ServerRemote
---@operator call: sea.ServerRemoteValidation
local ServerRemoteValidation = class()

---@param remote sea.ServerRemote
function ServerRemoteValidation:new(remote)
	self.remote = remote
	self.auth = remote.auth
	self.submission = SubmissionServerRemoteValidation(remote.submission)
	self.leaderboards = remote.leaderboards
end

---@return sea.User
function ServerRemoteValidation:getUser()
	return self.remote:getUser()
end

---@return sea.Session
function ServerRemoteValidation:getSession()
	return self.remote:getSession()
end

---@param msg string
---@return string
function ServerRemoteValidation:ping(msg)
	return self.remote:ping(msg)
end

return ServerRemoteValidation
