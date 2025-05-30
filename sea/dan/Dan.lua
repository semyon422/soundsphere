local class = require("class")

---@class sea.Dan
---@operator call: sea.Dan
---@field id integer
---@field chartmeta_keys sea.ChartmetaKey[]
---@field level number
---@field category string
---@field name string
---@field min_accuracy number?
---@field max_misses number?
local Dan = class()

return Dan
