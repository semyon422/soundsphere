local NoteData	= require("ncdk.NoteData")
local Modifier	= require("sphere.models.ModifierModel.Modifier")

local MultiplePlay = Modifier:new()

MultiplePlay.sequential = true
MultiplePlay.type = "NoteChartModifier"

MultiplePlay.name = "MultiplePlay"
MultiplePlay.shortName = "MP"

MultiplePlay.variableType = "number"
MultiplePlay.variableName = "value"
MultiplePlay.variableFormat = "%s"
MultiplePlay.variableRange = {1, 1, 3}
MultiplePlay.variableValues = {"DP", "TP", "QP"}
MultiplePlay.value = 1

MultiplePlay.modeNames = {"DP", "TP", "QP"}

MultiplePlay.tostring = function(self)
	return self.modeNames[self.value]
end

MultiplePlay.tojson = function(self)
	return ([[{"name":"%s","value":%s}]]):format(self.name, self.value)
end

MultiplePlay.apply = function(self)
	local noteChart = self.model.noteChart
	local value = self.value

	local inputCounts = {}
	for inputType, inputIndex in noteChart:getInputIteraator() do
		if not inputCounts[inputType] then
			local inputCount = noteChart.inputMode:getInputCount(inputType)
			if inputCount > 0 then
				inputCounts[inputType] = inputCount
			end
		end
	end

	local layerDataSequence = noteChart.layerDataSequence
	
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			local inputCount = inputCounts[noteData.inputType]
			if inputCount then
				for i = 1, value do
					local newInputIndex = noteData.inputIndex + inputCount * i

					local newNoteData = NoteData:new(noteData.timePoint)

					newNoteData.endNoteData = noteData.endNoteData
					newNoteData.noteType = noteData.noteType
					newNoteData.inputType = noteData.inputType
					newNoteData.inputIndex = newInputIndex
					newNoteData.sounds = noteData.sounds

					layerData:addNoteData(newNoteData)
					layerDataSequence:increaseInputCount(noteData.inputType, newInputIndex, 1)
				end
			end
		end
	end
	
	for inputType, inputCount in pairs(inputCounts) do
		noteChart.inputMode:setInputCount(inputType, inputCount * (value + 1))
	end

	noteChart:compute()
end

return MultiplePlay
