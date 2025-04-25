local class = require("class")

---@class sea.Chartfile
---@operator call: sea.Chartfile
---@field id integer
---@field hash string
---@field name string
---@field size integer
---@field set_id integer TODO
---@field compute_state sea.ComputeState
---@field creator_id integer
---@field submitted_at integer
local Chartfile = class()

return Chartfile
