local Modifier = require("sphere.game.ModifierManager.Modifier")

local ProMode = Modifier:new()

ProMode.name = "ProMode"

ProMode.apply = function(self)
	self.engine.score.promode = true
end

return ProMode
