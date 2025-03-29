local class = require("class")

---@class sea.SubmissionServerRemote
---@operator call: sea.SubmissionServerRemote
local SubmissionServerRemote = class()

---@param remote icc.Remote
function SubmissionServerRemote:new(remote)
	self.remote = remote
end

---@param chartplay_values sea.Chartplay
---@return true?
---@return string?
function SubmissionServerRemote:submitChartplay(chartplay_values)
	return self.remote.submission:submitChartplay(chartplay_values)
end

return SubmissionServerRemote
