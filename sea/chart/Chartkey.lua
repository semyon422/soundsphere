local class = require("class")
local table_util = require("table_util")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local ChartdiffKeyPart = require("sea.chart.ChartdiffKeyPart")

---@class sea.Chartkey: sea.ChartmetaKey, sea.ChartdiffKeyPart
---@operator call: sea.Chartkey
local Chartkey = class()

Chartkey.struct = {}
table_util.copy(ChartmetaKey.struct, Chartkey.struct)
table_util.copy(ChartdiffKeyPart.struct, Chartkey.struct)

assert(#table_util.keys(Chartkey.struct) == 5)

---@param key sea.Chartkey
---@return boolean
function Chartkey:equalsChartkey(key)
	return self:equalsChartmetaKey(key) and self:equalsChartdiffKeyPart(key)
end

return Chartkey
