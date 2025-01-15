local class = require("class")

---@class sea.Chartfile
---@operator call: sea.Chartfile
---@field id integer
---@field hash string
---@field name string
---@field size integer
---@field compute_state sea.ComputeState
local Chartfile = class()

return Chartfile
