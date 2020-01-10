local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")

local InconsequentialModifier = Modifier:new()

InconsequentialModifier.inconsequential = true

InconsequentialModifier.enabled = false

InconsequentialModifier.tojson = function(self)
	return ([[{"name":"%s"}]]):format(self.name)
end

return InconsequentialModifier
