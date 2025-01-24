local class = require("class")

---@class sea.ReplayfileReader
---@operator call: sea.ReplayfileReader
local ReplayfileReader = class()

---@param hash string
---@return {name: string, data: string}?
---@return string?
function ReplayfileReader:getFile(hash)
end

return ReplayfileReader
