local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")

local InconsequentialModifier = Modifier:new()

InconsequentialModifier.inconsequential = true

InconsequentialModifier.construct = function(self)
	self.value = false
end

return InconsequentialModifier
