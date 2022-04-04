local Modifier = require("sphere.models.ModifierModel.Modifier")

local NoMeasureLine = Modifier:new()

NoMeasureLine.type = "NoteChartModifier"
NoMeasureLine.interfaceType = "toggle"

NoMeasureLine.defaultValue = true
NoMeasureLine.name = "NoMeasureLine"
NoMeasureLine.shortName = "NML"

NoMeasureLine.getString = function(self, config)
	if not config.value then
		return
	end
	return Modifier.getString(self)
end

NoMeasureLine.apply = function(self, config)
	if config.value == 0 then
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
