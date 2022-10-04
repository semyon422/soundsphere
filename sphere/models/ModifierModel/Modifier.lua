local Class = require("Class")
local round = require("math_util").round

local Modifier = Class:new()

Modifier.getDefaultConfig = function(self)
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

Modifier.encode = function(self, config)
	local version = config.version or 0
	return ("%d,%s"):format(version, config.value)
end

Modifier.decode = function(self, configData)
	local config = self:getDefaultConfig()
	local version, value = configData:match("^(%d+),(.+)$")
	config.version = tonumber(version)
	config.value = self:decodeValue(value)
	return config
end

Modifier.decodeValue = function(self, s)
	if type(self.defaultValue) == "boolean" then
		return s == "true"
	elseif type(self.defaultValue) == "number" then
		return tonumber(s)
	end
	return s
end

Modifier.getValue = function(self, config)
	return config.value
end

Modifier.toNormValue = function(self, value)
	return (value - self.range[1]) / (self.range[2] - self.range[1])
end

Modifier.fromNormValue = function(self, normValue)
	normValue = math.min(math.max(normValue, 0), 1)
	return self.range[1] + round(normValue * (self.range[2] - self.range[1]), self.step)
end

Modifier.toIndexValue = function(self, value)
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

Modifier.fromIndexValue = function(self, indexValue)
	if not self.values then
		return self.range[1] + (indexValue - 1) * self.step
	end
	indexValue = math.min(math.max(indexValue, 1), #self.values)
	return self.values[indexValue] or ""
end

Modifier.getCount = function(self)
	if not self.values then
		return round((self.range[2] - self.range[1]) / self.step) + 1
	end
	return #self.values
end

Modifier.setValue = function(self, config, value)
	local range = self.range
	if type(self.defaultValue) == "number" then
		config.value = math.min(math.max(round(value, self.step), range[1]), range[2])
		return
	end
	config.value = value
end

Modifier.update = function(self) end

Modifier.receive = function(self, event) end

Modifier.checkValue = function(self, value)
	-- local range = self.range
	-- if value >= range[1] and value <= range[2] and value % 1 == 0 then
	-- 	return true
	-- end
end

Modifier.getString = function(self, config)
	return self.shortName or self.name
end

Modifier.getSubString = function(self, config)
	return nil
end

return Modifier
