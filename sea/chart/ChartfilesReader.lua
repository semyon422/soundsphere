local class = require("class")

---@class sea.ChartfilesReader
---@operator call: sea.ChartfilesReader
local ChartfilesReader = class()

---@param hash string
---@return {name: string, data: string}?
---@return string?
function ChartfilesReader:getFile(hash)
end

return ChartfilesReader
