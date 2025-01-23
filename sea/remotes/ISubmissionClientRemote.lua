local class = require("class")

---@class sea.ISubmissionClientRemote
---@operator call: sea.ISubmissionClientRemote
local ISubmissionClientRemote = class()

---@param hash string
---@return true?
---@return string?
function ISubmissionClientRemote:requireChartfileData(hash) end

---@param events_hash string
---@return true?
---@return string?
function ISubmissionClientRemote:requireEventsData(events_hash) end

return ISubmissionClientRemote
