local Class = require("aqua.util.Class")

local Modifier = Class:new()

Modifier.name = ""

Modifier.tostring = function(self)
	return self.name
end

return Modifier
