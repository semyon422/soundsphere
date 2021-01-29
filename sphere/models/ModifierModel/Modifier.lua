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

Modifier.checkValue = function(self, value)
	local range = self.range
	if value >= range[1] and value <= range[3] and (value - range[1]) % range[2] == 0 then
		return true
	end
end

Modifier.getString = function(self)
	return self.shortName
end

return Modifier
