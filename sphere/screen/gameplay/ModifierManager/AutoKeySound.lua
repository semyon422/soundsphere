local InconsequentialModifier = require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")
local NoteData = require("ncdk.NoteData")

local AutoKeySound = InconsequentialModifier:new()

AutoKeySound.name = "AutoKeySound"
AutoKeySound.shortName = "AKS"

AutoKeySound.type = "boolean"

AutoKeySound.apply = function(self)
	local noteChart = self.sequence.manager.noteChart
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart" then
				local soundNoteData = NoteData:new(noteData.timePoint)

				soundNoteData.noteType = "SoundNote"
				soundNoteData.inputType = "auto"
				soundNoteData.inputIndex = 0
				soundNoteData.sounds = noteData.sounds
				noteData.sounds = {}

				layerData:addNoteData(soundNoteData)
			end
		end
	end
end

return AutoKeySound
