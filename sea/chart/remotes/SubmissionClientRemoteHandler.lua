local class = require("class")

---@class sea.SubmissionClientRemoteHandler
---@operator call: sea.SubmissionClientRemoteHandler
local SubmissionClientRemoteHandler = class()

function SubmissionClientRemoteHandler:new()
end

---@param remote icc.Remote
---@param hash string
---@return {name: string, data: string}?
---@return string?
function SubmissionClientRemoteHandler:getChartfileData(remote, hash)
end

---@param remote icc.Remote
---@param events_hash string
---@return string?
---@return string?
function SubmissionClientRemoteHandler:getEventsData(remote, events_hash)
end

return SubmissionClientRemoteHandler
