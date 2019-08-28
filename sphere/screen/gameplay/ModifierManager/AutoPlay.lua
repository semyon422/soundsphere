local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")

local AutoPlay = InconsequentialModifier:new()

AutoPlay.name = "AutoPlay"
AutoPlay.shortName = "AP"

AutoPlay.apply = function(self)
	self.sequence.manager.engine.score.autoplay = self.value
end

return AutoPlay
