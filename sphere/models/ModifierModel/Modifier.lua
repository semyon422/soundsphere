local class = require("class")
local round = require("math_util").round
local table_util = require("table_util")

---@class sphere.Modifier
---@operator call: sphere.Modifier
local Modifier = class()

Modifier.version = 0
Modifier.name = ""

---@param value any
---@return number
function Modifier:toNormValue(value)
	local index = self:toIndexValue(value)
	return (index - 1) / (#self.values - 1)
end

---@param normValue number
---@return any
function Modifier:fromNormValue(normValue)
	normValue = math.min(math.max(normValue, 0), 1)
	local index = 1 + round(normValue * (#self.values - 1), 1)
	return self.values[index]
end

---@param value any
---@return number
function Modifier:toIndexValue(value)
	return table_util.indexof(self.values, value) or 1
end

---@param indexValue number
---@return any
function Modifier:fromIndexValue(indexValue)
	indexValue = math.min(math.max(indexValue, 1), #self.values)
	return self.values[indexValue]
end

---@return number
function Modifier:getCount()
	return #self.values
end

---@param modifierConfig table
---@param state table
function Modifier:applyMeta(modifierConfig, state) end

---@param modifierConfig table
function Modifier:apply(modifierConfig) end

---@param config table
---@return string
---@return string?
function Modifier:getString(config)
	return self.shortName or self.name
end

return Modifier
