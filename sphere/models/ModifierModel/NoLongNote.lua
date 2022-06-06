local Modifier = require("sphere.models.ModifierModel.Modifier")

local NoLongNote = Modifier:new()

NoLongNote.type = "NoteChartModifier"
NoLongNote.interfaceType = "toggle"

NoLongNote.defaultValue = true
NoLongNote.name = "NoLongNote"
NoLongNote.shortName = "NLN"

NoLongNote.getString = function(self, config)
	if not config.value then
		return
	end
	return Modifier.getString(self)
end

NoLongNote.apply = function(self, config)
	if not config.value then
		return
	end

	local noteChart = self.noteChartModel.noteChart

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
