local Class = require("aqua.util.Class")

local Modifier = Class:new()

Modifier.name = ""

Modifier.tostring = function(self)
	return self.name
end

Modifier.setValue = function(self, value)
	self.value = value
end

Modifier.getValue = function(self)
	return self.value
end

return Modifier
