local class = require("class")
local SubmissionClientRemote = require("sea.chart.remotes.SubmissionClientRemote")

---@class sea.SubmissionServerRemoteHandler
---@operator call: sea.SubmissionServerRemoteHandler
local SubmissionServerRemoteHandler = class()

---@param chartplays sea.Chartplays
function SubmissionServerRemoteHandler:new(chartplays)
	self.chartplays = chartplays
end

---@param remote icc.Remote
---@param user sea.User
---@param chartplay_values sea.Chartplay
---@return true?
---@return string?
function SubmissionServerRemoteHandler:submitChartplay(remote, user, chartplay_values)
	local client_remote = SubmissionClientRemote(remote.submission)
	self.chartplays:submit(user, client_remote, chartplay_values)
end

return SubmissionServerRemoteHandler
