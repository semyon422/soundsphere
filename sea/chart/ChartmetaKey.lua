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

return ChartmetaKey
