local class = require("class")

---@class sph.LineNote
---@field column integer
---@field type string

---@class sph.Line
---@operator call: sph.Line
---@field comment string?
---@field notes sph.LineNote[]?
---@field offset number?
---@field time ncdk.Fraction?
---@field same true?
---@field visual string?
---@field measure ncdk.Fraction?
---@field sounds integer[]?
---@field volume integer[]?
---@field velocity number[]?
---@field expand number?
local Line = class()

return Line
