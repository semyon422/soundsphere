local Class = require("aqua.util.Class")
local round = require("aqua.math").round

local Modifier = Class:new()

Modifier.construct = function(self)
	self.config = self:getDefaultConfig()
end

Modifier.getDefaultConfig = function(self)
	return {
		name = self.name,
		value = self.defaultValue
	}
end

Modifier.name = ""
Modifier.shortName = ""
Modifier.format = "%d"
Modifier.defaultValue = 0
Modifier.range = {0, 1}
Modifier.step = 1
Modifier.offset = 0
Modifier.display = {"false", "true"}

Modifier.getRealValue = function(self, config)
	config = config or self.config
	return self.offset + config.value * self.step
end

Modifier.getNormalizedValue = function(self, config)
	config = config or self.config
	return (config.value - self.range[1]) / (self.range[2] - self.range[1])
end

Modifier.fromNormalizedValue = function(self, value)
	return round(self.range[1] + value * (self.range[2] - self.range[1]))
end

Modifier.update = function(self) end

Modifier.receive = function(self, event) end

Modifier.checkValue = function(self, value)
	local range = self.range
	if value >= range[1] and value <= range[2] and value % 1 == 0 then
		return true
	end
end

Modifier.getString = function(self, config)
	return self.shortName
end

return Modifier
