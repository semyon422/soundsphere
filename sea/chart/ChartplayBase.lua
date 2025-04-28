local table_util = require("table_util")
local valid = require("valid")
local ChartdiffKeyPart = require("sea.chart.ChartdiffKeyPart")
local RateType = require("sea.chart.RateType")
local Timings = require("sea.chart.Timings")
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
---@field subtimings sea.Subtimings?
---@field healths sea.Healths?
---@field columns_order integer[]? nil - unchanged
--- METADATA not for computation
---@field custom boolean
---@field const boolean
---@field rate_type sea.RateType
local ChartplayBase = ChartdiffKeyPart + {}

function ChartplayBase:new()
	ChartdiffKeyPart.new(self)

	self.nearest = false
	self.tap_only = false
	self.timings = Timings("sphere")
	self.subtimings = nil
	self.healths = nil
	self.columns_order = nil

	self.custom = false
	self.const = false
	self.rate_type = "linear"
end

ChartplayBase.struct = {
	-- Other
	nearest = types.boolean,
	tap_only = types.boolean,
	timings = valid.optional(chart_types.timings),
	subtimings = valid.optional(chart_types.subtimings),
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
---@return boolean?
---@return string?
function ChartplayBase:equalsChartplayBase(values)
	return valid.equals(table_util.sub(self, keys), table_util.sub(values, keys))
end

---@param base sea.ChartplayBase
function ChartplayBase:importChartplayBase(base)
	for k in pairs(ChartplayBase.struct) do
		self[k] = base[k] ---@diagnostic disable-line
	end
end

---@param base sea.ChartplayBase
function ChartplayBase:exportChartplayBase(base)
	for k in pairs(ChartplayBase.struct) do
		base[k] = self[k] ---@diagnostic disable-line
	end
end

return ChartplayBase
