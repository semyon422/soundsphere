local ModifierManager = {}

ModifierManager.modifiers = {
	require("sphere.game.ModifierManager.AutoPlay"),
	require("sphere.game.ModifierManager.NoLongNote"),
	require("sphere.game.ModifierManager.NoMeasureLine"),
	require("sphere.game.ModifierManager.CMod"),
	require("sphere.game.ModifierManager.FullLongNote"),
}

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

return ModifierManager
