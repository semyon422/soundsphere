local Class = require("aqua.util.Class")

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
Modifier.range = {0, 1, 1}
Modifier.display = {"false", "true"}

Modifier.update = function(self) end

Modifier.receive = function(self, event) end

Modifier.getString = function(self)
	return self.shortName
end

return Modifier
