local ModifierSequence = require("sphere.screen.gameplay.ModifierManager.ModifierSequence")

local ModifierManager = {}

ModifierManager.modifiers = {
	require("sphere.screen.gameplay.ModifierManager.AutoPlay"),
	require("sphere.screen.gameplay.ModifierManager.ProMode"),
	require("sphere.screen.gameplay.ModifierManager.SetInput"),
	require("sphere.screen.gameplay.ModifierManager.Mirror"),
	require("sphere.screen.gameplay.ModifierManager.NoLongNote"),
	require("sphere.screen.gameplay.ModifierManager.NoMeasureLine"),
	require("sphere.screen.gameplay.ModifierManager.CMod"),
	require("sphere.screen.gameplay.ModifierManager.FullLongNote"),
	require("sphere.screen.gameplay.ModifierManager.ToOsu"),
}

ModifierManager.AutoPlay = require("sphere.screen.gameplay.ModifierManager.AutoPlay")
ModifierManager.ProMode = require("sphere.screen.gameplay.ModifierManager.ProMode")
ModifierManager.SetInput = require("sphere.screen.gameplay.ModifierManager.SetInput")
ModifierManager.Mirror = require("sphere.screen.gameplay.ModifierManager.Mirror")
ModifierManager.NoLongNote = require("sphere.screen.gameplay.ModifierManager.NoLongNote")
ModifierManager.NoMeasureLine = require("sphere.screen.gameplay.ModifierManager.NoMeasureLine")
ModifierManager.CMod = require("sphere.screen.gameplay.ModifierManager.CMod")
ModifierManager.FullLongNote = require("sphere.screen.gameplay.ModifierManager.FullLongNote")
ModifierManager.ToOsu = require("sphere.screen.gameplay.ModifierManager.ToOsu")

ModifierManager.sequence = ModifierSequence:new()
ModifierManager.sequence.manager = ModifierManager

ModifierManager.engineModifiers = {
	ModifierManager.AutoPlay,
	ModifierManager.ProMode,
	ModifierManager.SetInput,
}

ModifierManager.noteChartModifiers = {
	ModifierManager.CMod,
	ModifierManager.Mirror,
	ModifierManager.NoLongNote,
	ModifierManager.FullLongNote,
	ModifierManager.NoMeasureLine,
	ModifierManager.ToOsu
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
