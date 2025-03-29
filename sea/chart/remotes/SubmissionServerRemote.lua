local class = require("class")

---@class sea.SubmissionServerRemote: sea.IServerRemote
---@operator call: sea.SubmissionServerRemote
local SubmissionServerRemote = class()

---@param chartplays sea.Chartplays
function SubmissionServerRemote:new(chartplays)
	self.chartplays = chartplays
end

---@param chartplay_values sea.Chartplay
---@return true?
---@return string?
function SubmissionServerRemote:submitChartplay(chartplay_values)
	self.chartplays:submit(self.user, self.remote.submission, chartplay_values)
end

return SubmissionServerRemote
