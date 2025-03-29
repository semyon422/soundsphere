local class = require("class")

---@class sea.SubmissionClientRemote
---@operator call: sea.SubmissionClientRemote
local SubmissionClientRemote = class()

---@param remote icc.Remote
function SubmissionClientRemote:new(remote)
	self.remote = remote
end

---@param hash string
---@return {name: string, data: string}?
---@return string?
function SubmissionClientRemote:getChartfileData(hash)
	return self.remote:getChartfileData(hash)
end

---@param events_hash string
---@return string?
---@return string?
function SubmissionClientRemote:getEventsData(events_hash)
	return self.remote:getEventsData(events_hash)
end

return SubmissionClientRemote
