local Modifier = require("sphere.game.modifiers.Modifier")
local ModifierSequence = require("sphere.game.ModifierSequence")

local AutoPlay = require("sphere.game.modifiers.AutoPlay")

local ModifierManager = {}

ModifierManager.apply = function(self)
	if not self.modifierSequence then
		return
	end
	
	self.modifierSequence.engine = self.engine
	self.modifierSequence.noteChart = self.noteChart
	self.modifierSequence.noteSkin = self.noteSkin
	self.modifierSequence.playField = self.playField
	
	self.modifierSequence:apply()
end

ModifierManager.load = function(self)
	self.modifierSequence = ModifierSequence:new()
	self.modifierSequence:add(AutoPlay:new())
end

return ModifierManager
