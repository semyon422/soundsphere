local class = require("class")

---@class sea.DifftableChartmeta
---@operator call: sea.DifftableChartmeta
---@field id integer
---@field user_id integer
---@field difftable_id integer
---@field hash string
---@field index integer
---@field level number
---@field is_deleted boolean
---@field created_at integer
---@field updated_at integer
---@field change_index integer
--- joined/preloaded
---@field chartmeta_id integer?
---@field chartmeta sea.Chartmeta?
---@field user sea.User?
---@field difftable sea.Difftable?
local DifftableChartmeta = class()

return DifftableChartmeta
