local class = require("class")
local SubmissionServerRemoteHandler = require("sea.chart.remotes.SubmissionServerRemoteHandler")

---@class sea.ServerRemoteHandler
---@operator call: sea.ServerRemoteHandler
local ServerRemoteHandler = class()

---@param domain sea.Domain
function ServerRemoteHandler:new(domain)
	self.submission = SubmissionServerRemoteHandler(domain.chartplays)
end

---@param remote icc.Remote
---@param msg any
function ServerRemoteHandler:ping(remote, msg)
	return msg
end

return ServerRemoteHandler
