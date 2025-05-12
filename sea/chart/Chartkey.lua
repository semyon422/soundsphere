local class = require("class")
local valid = require("valid")
local table_util = require("table_util")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local ChartdiffKeyPart = require("sea.chart.ChartdiffKeyPart")

---@class sea.Chartkey: sea.ChartmetaKey, sea.ChartdiffKeyPart
---@operator call: sea.Chartkey
local Chartkey = class()

---@type {[string]: function}
Chartkey.struct = {}
table_util.copy(ChartmetaKey.struct, Chartkey.struct)
table_util.copy(ChartdiffKeyPart.struct, Chartkey.struct)

assert(#table_util.keys(Chartkey.struct) == 5)

local validate_chartkey = valid.struct(Chartkey.struct)

---@return true?
---@return string|valid.Errors?
function Chartkey:validate()
	return validate_chartkey(self)
end

---@param key sea.Chartkey
---@return boolean
function Chartkey:equalsChartkey(key)
	return self:equalsChartmetaKey(key) and self:equalsChartdiffKeyPart(key)
end

---@param chartkey sea.ChartmetaKey
function Chartkey:importChartkey(chartkey)
	for k in pairs(Chartkey.struct) do
		self[k] = chartkey[k] ---@diagnostic disable-line
	end
end

---@param chartkey sea.ChartmetaKey
function Chartkey:exportChartkey(chartkey)
	for k in pairs(Chartkey.struct) do
		chartkey[k] = self[k] ---@diagnostic disable-line
	end
end

return Chartkey
