local Modifier = require("sphere.models.RhythmModel.ModifierManager.Modifier")

local NoLongNote = Modifier:new()

NoLongNote.inconsequential = true
NoLongNote.type = "NoteChartModifier"

NoLongNote.name = "NoLongNote"
NoLongNote.shortName = "NLN"

NoLongNote.variableType = "boolean"

NoLongNote.apply = function(self)
	local noteChart = self.sequence.manager.noteChart
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.noteType == "LongNoteStart" or noteData.noteType == "LaserNoteStart" then
				noteData.noteType = "ShortNote"
			elseif noteData.noteType == "LongNoteEnd" or noteData.noteType == "LaserNoteEnd" then
				noteData.noteType = "Ignore"
			end
		end
	end
end

return NoLongNote
