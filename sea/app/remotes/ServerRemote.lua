local class = require("class")
local SubmissionServerRemote = require("sea.chart.remotes.SubmissionServerRemote")

---@class sea.ServerRemote: sea.IServerRemote
---@operator call: sea.ServerRemote
local ServerRemote = class()

---@param domain sea.Domain
function ServerRemote:new(domain)
	self.submission = SubmissionServerRemote(domain.chartplays)
end

---@param msg string
---@return string
function ServerRemote:ping(msg)
	return msg .. "world" .. self.user.id
end

return ServerRemote
