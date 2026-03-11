---@class rizu.dlc.IDlcProvider
local IDlcProvider = {}

---@param query string
---@param type rizu.dlc.DlcType
---@param filters table?
---@return table[]? results, string? error
function IDlcProvider:search(query, type, filters) end

---@param id string|number
---@return table? metadata, string? error
function IDlcProvider:getMetadata(id) end

---@param id string|number
---@return string? url, string? error
function IDlcProvider:getDownloadUrl(id) end

return IDlcProvider
