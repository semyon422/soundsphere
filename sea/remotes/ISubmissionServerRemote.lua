local class = require("class")

---@class sea.ISubmissionServerRemote
---@operator call: sea.ISubmissionServerRemote
local ISubmissionServerRemote = class()

---@param hash string
---@param name string
---@param size integer
---@param data string
---@return true?
---@return string?
function ISubmissionServerRemote:submitChartfileData(hash, name, size, data) end

---@param events_hash string
---@param size integer
---@param data string
---@return true?
---@return string?
function ISubmissionServerRemote:submitEventsData(events_hash, size, data) end

return ISubmissionServerRemote
