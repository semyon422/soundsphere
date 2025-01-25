local class = require("class")

---@class sea.ISubmissionClientRemote
---@operator call: sea.ISubmissionClientRemote
local ISubmissionClientRemote = class()

---@param hash string
---@return {name: string, data: string}?
---@return string?
function ISubmissionClientRemote:getChartfileData(hash) end

---@param events_hash string
---@return string?
---@return string?
function ISubmissionClientRemote:getEventsData(events_hash) end

return ISubmissionClientRemote
