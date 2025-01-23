local class = require("class")

---@class sea.ISubmissionServerRemote
---@operator call: sea.ISubmissionServerRemote
local ISubmissionServerRemote = class()

---@param hash string
---@return true?
---@return string?
function ISubmissionServerRemote:requireChartfileData(hash) end

---@param events_hash string
---@return true?
---@return string?
function ISubmissionServerRemote:requireEventsData(events_hash) end

return ISubmissionServerRemote
