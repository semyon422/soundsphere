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

return ModifierManager
