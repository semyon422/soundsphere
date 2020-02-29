local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local AutoPlay = InconsequentialModifier:new()

AutoPlay.name = "AutoPlay"
AutoPlay.shortName = "AP"

AutoPlay.type = "boolean"

AutoPlay.apply = function(self)
	self.sequence.manager.logicEngine.score.autoplay = true
end

return AutoPlay
