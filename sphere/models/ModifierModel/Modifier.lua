local class = require("class")
local round = require("math_util").round

---@class sphere.Modifier
---@operator call: sphere.Modifier
local Modifier = class()

---@return table
function Modifier:getDefaultConfig()
	return {
		name = self.name,
		version = self.version,
		value = self.defaultValue
	}
end

Modifier.version = 0
Modifier.name = ""
Modifier.format = "%d"
Modifier.defaultValue = 0
Modifier.range = {0, 1}
Modifier.step = 1

---@param config table
---@return string
function Modifier:encode(config)
	local version = config.version or 0
	return ("%d,%s"):format(version, config.value)
end

---@param configData string
---@return table
function Modifier:decode(configData)
	local config = self:getDefaultConfig()
	local version, value = configData:match("^(%d+),(.+)$")
	config.version = tonumber(version)
	config.value = self:decodeValue(value)
	return config
end

---@param s string
---@return string|boolean|number
function Modifier:decodeValue(s)
	if type(self.defaultValue) == "boolean" then
		return s == "true"
	elseif type(self.defaultValue) == "number" then
		return tonumber(s)
	end
	return s
end

---@param config table
---@return any
function Modifier:getValue(config)
	return config.value
end

---@param value number
---@return number
function Modifier:toNormValue(value)
	return (value - self.range[1]) / (self.range[2] - self.range[1])
end

---@param normValue number
---@return number
function Modifier:fromNormValue(normValue)
	normValue = math.min(math.max(normValue, 0), 1)
	return self.range[1] + round(normValue * (self.range[2] - self.range[1]), self.step)
end

---@param value any
---@return number
function Modifier:toIndexValue(value)
	if not self.values then
		return round((value - self.range[1]) / self.step) + 1
	end
	for i, currentValue in ipairs(self.values) do
		if value == currentValue then
			return i
		end
	end
	return 1
end

---@param indexValue number
---@return any
function Modifier:fromIndexValue(indexValue)
	if not self.values then
		return self.range[1] + (indexValue - 1) * self.step
	end
	indexValue = math.min(math.max(indexValue, 1), #self.values)
	return self.values[indexValue] or ""
end

---@return number
function Modifier:getCount()
	if not self.values then
		return round((self.range[2] - self.range[1]) / self.step) + 1
	end
	return #self.values
end

---@param config table
---@param value any
function Modifier:setValue(config, value)
	local range = self.range
	if type(self.defaultValue) == "number" then
		config.value = math.min(math.max(round(value, self.step), range[1]), range[2])
		return
	end
	config.value = value
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
