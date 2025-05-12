local class = require("class")
local valid = require("valid")
local table_util = require("table_util")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local ChartdiffKeyPart = require("sea.chart.ChartdiffKeyPart")

---@class sea.ChartdiffKey: sea.ChartmetaKey, sea.ChartdiffKeyPart
---@operator call: sea.ChartdiffKey
local ChartdiffKey = class()

---@type {[string]: function}
ChartdiffKey.struct = {}
table_util.copy(ChartmetaKey.struct, ChartdiffKey.struct)
table_util.copy(ChartdiffKeyPart.struct, ChartdiffKey.struct)

assert(#table_util.keys(ChartdiffKey.struct) == 5)

local validate_chartdiff_key = valid.struct(ChartdiffKey.struct)

---@return true?
---@return string|valid.Errors?
function ChartdiffKey:validate()
	return validate_chartdiff_key(self)
end

---@param key sea.ChartdiffKey
---@return boolean
function ChartdiffKey:equalsChartdiffKey(key)
	return self:equalsChartmetaKey(key) and self:equalsChartdiffKeyPart(key)
end

---@param chartdiff_key sea.ChartmetaKey
function ChartdiffKey:importChartdiffKey(chartdiff_key)
	for k in pairs(ChartdiffKey.struct) do
		self[k] = chartdiff_key[k] ---@diagnostic disable-line
	end
end

---@param chartdiff_key sea.ChartmetaKey
function ChartdiffKey:exportChartdiffKey(chartdiff_key)
	for k in pairs(ChartdiffKey.struct) do
		chartdiff_key[k] = self[k] ---@diagnostic disable-line
	end
end

return ChartdiffKey
