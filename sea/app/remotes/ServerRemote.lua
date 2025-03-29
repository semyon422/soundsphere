local class = require("class")
local SubmissionServerRemote = require("sea.chart.remotes.SubmissionServerRemote")

---@class sea.ServerRemote
---@operator call: sea.ServerRemote
local ServerRemote = class()

---@param remote icc.Remote
function ServerRemote:new(remote)
	self.remote = remote
	self.submission = SubmissionServerRemote(remote.submission)
end

---@param msg any
---@return any
function ServerRemote:ping(msg)
	return self.remote:ping(msg)
end

return ServerRemote
