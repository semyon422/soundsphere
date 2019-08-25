local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")

local SetInput = Modifier:new()

SetInput.name = "SetInput"

SetInput.apply = function(self)
	self.engine.score.setinput = true
end

return SetInput
