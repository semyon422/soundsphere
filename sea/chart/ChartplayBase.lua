local table_util = require("table_util")
local valid = require("valid")
local ChartdiffKeyPart = require("sea.chart.ChartdiffKeyPart")
local RateType = require("sea.chart.RateType")
local types = require("sea.shared.types")
local chart_types = require("sea.chart.types")

---@class sea.ChartplayBase: sea.ChartdiffKeyPart
---@operator call: sea.ChartplayBase
--- REQUIRED for computation
---   ChartdiffKeyPart: modifiers, rate, mode
---   Other
---@field nearest boolean
---@field tap_only boolean - like NoLongNote
---@field timings sea.Timings?
---@field subtimings sea.Subtimings
---@field healths sea.Healths?
---@field columns_order integer[]? nil - unchanged
--- METADATA not for computation
---@field custom boolean
---@field const boolean
---@field rate_type sea.RateType
local ChartplayBase = ChartdiffKeyPart + {}

ChartplayBase.struct = {
	-- Other
	nearest = types.boolean,
	tap_only = types.boolean,
	timings = valid.optional(chart_types.timings),
	subtimings = chart_types.subtimings,
	healths = valid.optional(chart_types.healths),
	columns_order = chart_types.columns_order,
	-- METADATA
	custom = types.boolean,
	const = types.boolean,
	rate_type = types.new_enum(RateType),
}
table_util.copy(ChartdiffKeyPart.struct, ChartplayBase.struct)

assert(#table_util.keys(ChartplayBase.struct) == 12)

local keys = table_util.keys(ChartplayBase.struct)

---@param values sea.ChartplayBase
---@return boolean
function ChartplayBase:equalsChartplayBase(values)
	return table_util.subequal(self, values, keys, table_util.equal)
end

return ChartplayBase
