local Chartplay = require("sea.chart.Chartplay")

---@class sea.Chartplayview: sea.Chartplay
---@operator call: sea.Chartplayview
---@field chartplay_id integer
---@field chartdiff_id integer
---@field chartmeta_id integer
---@field difftable_id integer
---@field difftable_level number
---@field chartmeta_level number
---@field chartmeta_timings sea.Timings
---@field chartmeta_healths sea.Healths
---@field chartmeta_inputmode string
---@field chartdiff_inputmode string
---@field notes_count integer
local Chartplayview = Chartplay + {}

return Chartplayview
