local class = require("class")

---@class sea.Dan
---@operator call: sea.Dan
---@field id integer
---@field chartmetas sea.Chartmeta[]
---@field level number
---@field category string
---@field name string
---@field timings sea.Timings
---@field subtimings sea.Subtimings?
---@field min_accuracy number?
---@field max_misses number?
local Dan = class()

return Dan
