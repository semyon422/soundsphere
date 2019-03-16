local Modifier = require("sphere.game.modifiers.Modifier")

local AutoPlay = Modifier:new()

AutoPlay.name = "AutoPlay"

AutoPlay.apply = function(self)
	self.sequence.engine.autoplay = true
end

return AutoPlay
