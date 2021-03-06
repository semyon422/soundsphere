local NoteData	= require("ncdk.NoteData")
local Modifier	= require("sphere.models.ModifierModel.Modifier")

local MultiOverPlay = Modifier:new()

MultiOverPlay.sequential = true
MultiOverPlay.type = "NoteChartModifier"

MultiOverPlay.name = "MultiOverPlay"
MultiOverPlay.shortName = "MOP"

MultiOverPlay.variableValues = {"DO", "TO", "QO"}
MultiOverPlay.modeNames = {"DO", "TO", "QO"}

MultiOverPlay.defaultValue = 1
MultiOverPlay.range = {1, 3}

MultiOverPlay.getString = function(self)
	return self.modeNames[self.value]
end

MultiOverPlay.getRealValue = function(self, config)
	config = config or self.config
	return self.modeNames[config.value]
end

MultiOverPlay.apply = function(self)
	local noteChart = self.noteChartModel.noteChart
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
                local inputIndex = noteData.inputIndex
                local newInputIndex = (inputIndex - 1) * (value + 1) + 1
				layerDataSequence:increaseInputCount(noteData.inputType, inputIndex, -1)
				layerDataSequence:increaseInputCount(noteData.inputType, newInputIndex, 1)
				noteData.inputIndex = newInputIndex
				for i = 1, value do
					newInputIndex = newInputIndex + i

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

return MultiOverPlay
