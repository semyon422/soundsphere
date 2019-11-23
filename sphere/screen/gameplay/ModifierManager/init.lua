local ModifierSequence = require("sphere.screen.gameplay.ModifierManager.ModifierSequence")

local ModifierManager = {}

ModifierManager.sequence = ModifierSequence:new()
ModifierManager.sequence.manager = ModifierManager

ModifierManager.apply = function(self)
	return self.sequence:apply()
end

ModifierManager.getSequence = function(self)
	return self.sequence
end

return ModifierManager
