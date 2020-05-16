local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")

local Mirror = Modifier:new()

Mirror.sequential = true
Mirror.type = "NoteChartModifier"

Mirror.name = "Mirror"
Mirror.shortName = "Mirror"

Mirror.variableType = "boolean"

Mirror.apply = function(self)
	local noteChart = self.sequence.manager.noteChart
	local layerDataSequence = noteChart.layerDataSequence
	
	local inputCounts = {}
	for inputType, inputIndex in noteChart:getInputIteraator() do
		if not inputCounts[inputType] then
			inputCounts[inputType] = noteChart.inputMode:getInputCount(inputType)
		end
	end
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			if inputCounts[noteData.inputType] > 0 then
				layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, -1)
				noteData.inputIndex = inputCounts[noteData.inputType] - noteData.inputIndex + 1
				layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
			end
		end
	end
end

return Mirror
