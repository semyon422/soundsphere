local class = require("class")
local types = require("sea.shared.types")
local table_util = require("table_util")

---@class sea.ChartmetaKey
---@operator call: sea.ChartmetaKey
---@field hash string
---@field index integer
local ChartmetaKey = class()

ChartmetaKey.struct = {
	hash = types.md5hash,
	index = types.index,
}

assert(#table_util.keys(ChartmetaKey.struct) == 2)

---@param key sea.ChartmetaKey
---@return boolean
function ChartmetaKey:equalsChartmetaKey(key)
	return
		self.hash == key.hash and
		self.index == key.index
end

---@param chartmeta_key sea.ChartmetaKey
function ChartmetaKey:importChartmetaKey(chartmeta_key)
	for k in pairs(ChartmetaKey.struct) do
		self[k] = chartmeta_key[k] ---@diagnostic disable-line
	end
end

---@param chartmeta_key sea.ChartmetaKey
function ChartmetaKey:exportChartmetaKey(chartmeta_key)
	for k in pairs(ChartmetaKey.struct) do
		chartmeta_key[k] = self[k] ---@diagnostic disable-line
	end
end

return ChartmetaKey
