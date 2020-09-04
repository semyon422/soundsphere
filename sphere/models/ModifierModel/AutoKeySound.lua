local Modifier = require("sphere.models.ModifierModel.Modifier")
local NoteData = require("ncdk.NoteData")

local AutoKeySound = Modifier:new()

AutoKeySound.inconsequential = true
AutoKeySound.type = "NoteChartModifier"

AutoKeySound.name = "AutoKeySound"
AutoKeySound.shortName = "AKS"

AutoKeySound.variableType = "boolean"

AutoKeySound.apply = function(self)
	local noteChart = self.noteChartModel.noteChart
	
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
