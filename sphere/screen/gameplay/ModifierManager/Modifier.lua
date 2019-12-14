local Class = require("aqua.util.Class")

local Modifier = Class:new()

Modifier.name = ""

Modifier.update = function(self) end

Modifier.tostring = function(self)
	return self.shortName
end

Modifier.setValue = function(self, value)
	self.value = value
end

Modifier.getValue = function(self)
	return self.value
end

return Modifier
