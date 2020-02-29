local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local SetInput = InconsequentialModifier:new()

SetInput.name = "SetInput"
SetInput.shortName = "SetInput"

SetInput.type = "boolean"

SetInput.apply = function(self)
	self.sequence.manager.logicEngine.score.setinput = true
end

return SetInput
