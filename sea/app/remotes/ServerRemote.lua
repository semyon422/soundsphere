local class = require("class")
local SubmissionServerRemote = require("sea.chart.remotes.SubmissionServerRemote")

---@class sea.ServerRemote: sea.IServerRemote
---@operator call: sea.ServerRemote
local ServerRemote = class()

---@param domain sea.Domain
---@param repos sea.Repos
function ServerRemote:new(domain, repos)
	self.submission = SubmissionServerRemote(domain.chartplays, repos.chartfiles_repo)
end

---@param msg string
---@return string
function ServerRemote:ping(msg)
	return msg .. "world" .. self.user.id
end

return ServerRemote
