local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local ProMode = InconsequentialModifier:new()

ProMode.name = "ProMode"
ProMode.shortName = "ProMode"

ProMode.type = "boolean"

ProMode.apply = function(self)
	self.sequence.manager.logicEngine.score.promode = true
end

return ProMode
