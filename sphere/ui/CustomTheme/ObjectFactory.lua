local Button = require("sphere.ui.CustomTheme.Button")

local ObjectFactory = {}

ObjectFactory.getObject = function(self, objectData)
	return Button:new(nil, objectData)
end

return ObjectFactory
