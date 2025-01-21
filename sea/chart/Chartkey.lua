local class = require("class")
local table_util = require("table_util")

---@class sea.Chartkey
---@operator call: sea.Chartkey
---@field hash string
---@field index integer
---@field modifiers sea.Modifier[]
---@field rate number
local Chartkey = class()

---@param key sea.Chartkey
---@return boolean
function Chartkey:equalsChartkey(key)
	return
		self.hash == key.hash and
		self.index == key.index and
		table_util.deepequal(self.modifiers, key.modifiers) and
		self.rate == key.rate
end

return Chartkey
