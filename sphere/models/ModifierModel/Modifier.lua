local Class = require("aqua.util.Class")

local Modifier = Class:new()

Modifier.name = ""
Modifier.shortName = ""

Modifier.update = function(self) end

Modifier.receive = function(self, event) end

Modifier.tostring = function(self)
	return self.shortName
end

Modifier.tojson = function(self)
	return ([[{"name":"%s"}]]):format(self.name)
end

return Modifier
