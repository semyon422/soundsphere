local Modifier = require("sphere.models.ModifierModel.Modifier")

local NoMeasureLine = Modifier:new()

NoMeasureLine.type = "NoteChartModifier"

NoMeasureLine.name = "NoMeasureLine"
NoMeasureLine.shortName = "NML"

NoMeasureLine.apply = function(self)
	local config = self.config
	if not config.value then
		return
	end

	local noteChart = self.noteChartModel.noteChart

	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)

		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)

			if noteData.noteType == "LineNoteStart" then
				noteData.noteType = "Ignore"
			elseif noteData.noteType == "LineNoteEnd" then
				noteData.noteType = "Ignore"
			end
		end
	end
end

return NoMeasureLine
