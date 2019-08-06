local Modifier = require("sphere.game.ModifierManager.Modifier")

local Pitch = Modifier:new()

Pitch.name = "Pitch"

Pitch.apply = function(self)
	self.engine.pitch = true
end

return Pitch
