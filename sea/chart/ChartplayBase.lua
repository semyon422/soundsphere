local Chartkey = require("sea.chart.Chartkey")

---@class sea.ChartplayBase: sea.Chartkey
---@operator call: sea.ChartplayBase
--- REQUIRED for computation
---   Chartkey: hash, index, modifiers, rate, mode
---   Other
---@field nearest boolean
---@field tap_only boolean - like NoLongNote
---@field timings sea.Timings
---@field subtimings sea.Subtimings
---@field healths sea.Healths
---@field columns_order integer[]? nil - unchanged
--- METADATA not for computation
---@field custom boolean
---@field const boolean
---@field pause_count integer
---@field created_at integer
---@field rate_type sea.RateType
local ChartplayBase = Chartkey + {}

return ChartplayBase
