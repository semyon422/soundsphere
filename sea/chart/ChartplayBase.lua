local table_util = require("table_util")
local Chartkey = require("sea.chart.Chartkey")
local RateType = require("sea.chart.RateType")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")

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

ChartplayBase.struct = {
	-- Other
	nearest = types.boolean,
	tap_only = types.boolean,
	timings = chart_types.timings,
	subtimings = chart_types.subtimings,
	healths = chart_types.healths,
	columns_order = chart_types.columns_order,
	-- METADATA
	custom = types.boolean,
	const = types.boolean,
	pause_count = types.count,
	created_at = types.time,
	rate_type = types.new_enum(RateType),
}
table_util.copy(Chartkey.struct, ChartplayBase.struct)

return ChartplayBase
