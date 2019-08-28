local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local Pitch = InconsequentialModifier:new()

Pitch.name = "Pitch"
Pitch.shortName = "Pitch"

Pitch.apply = function(self)
	self.sequence.manager.engine.pitch = true
end

return Pitch
