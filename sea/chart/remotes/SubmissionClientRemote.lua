local class = require("class")

---@class sea.SubmissionClientRemote
---@operator call: sea.SubmissionClientRemote
local SubmissionClientRemote = class()

function SubmissionClientRemote:new()
end

---@param remote icc.Remote
---@param hash string
---@return {name: string, data: string}?
---@return string?
function SubmissionClientRemote:getChartfileData(remote, hash)
end

---@param remote icc.Remote
---@param events_hash string
---@return string?
---@return string?
function SubmissionClientRemote:getEventsData(remote, events_hash)
end

return SubmissionClientRemote
