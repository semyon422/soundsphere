local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local SetInput = InconsequentialModifier:new()

SetInput.name = "SetInput"
SetInput.shortName = "SetInput"

SetInput.apply = function(self)
	self.sequence.manager.engine.score.setinput = true
end

return SetInput
