local ModifierSequence = require("sphere.game.ModifierManager.ModifierSequence")

local ModifierManager = {}

ModifierManager.modifiers = {
	require("sphere.game.ModifierManager.AutoPlay"),
	require("sphere.game.ModifierManager.NoLongNote"),
	require("sphere.game.ModifierManager.NoMeasureLine"),
	require("sphere.game.ModifierManager.CMod"),
	require("sphere.game.ModifierManager.FullLongNote"),
}

ModifierManager.AutoPlay = require("sphere.game.ModifierManager.AutoPlay")
ModifierManager.NoLongNote = require("sphere.game.ModifierManager.NoLongNote")
ModifierManager.NoMeasureLine = require("sphere.game.ModifierManager.NoMeasureLine")
ModifierManager.CMod = require("sphere.game.ModifierManager.CMod")
ModifierManager.FullLongNote = require("sphere.game.ModifierManager.FullLongNote")

ModifierManager.sequence = ModifierSequence:new()
ModifierManager.sequence.manager = ModifierManager

ModifierManager.engineModifiers = {
	ModifierManager.AutoPlay
}

ModifierManager.noteChartModifiers = {
	ModifierManager.CMod,
	ModifierManager.NoLongNote,
	ModifierManager.FullLongNote,
	ModifierManager.NoMeasureLine
}

ModifierManager.noteSkinModifiers = {}

ModifierManager.getEngineModifiers = function(self)
	return self.engineModifiers
end

ModifierManager.getNoteChartModifiers = function(self)
	return self.noteChartModifiers
end

ModifierManager.getNoteSkinModifiers = function(self)
	return self.noteSkinModifiers
end

ModifierManager.apply = function(self)
	return self.sequence:apply()
end

ModifierManager.getSequence = function(self)
	return self.sequence
end

return ModifierManager
