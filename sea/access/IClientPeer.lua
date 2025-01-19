local class = require("class")

---@class sea.IClientPeer
---@operator call: sea.IClientPeer
local IClientPeer = class()

---@param hash string
---@return true?
---@return string?
function IClientPeer:requireChartfileData(hash) end

---@param events_hash string
---@return true?
---@return string?
function IClientPeer:requireEventsData(events_hash) end

return IClientPeer
