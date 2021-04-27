local NoteData	= require("ncdk.NoteData")
local Modifier	= require("sphere.models.ModifierModel.Modifier")

local MultiOverPlay = Modifier:new()

MultiOverPlay.type = "NoteChartModifier"
MultiOverPlay.interfaceType = "stepper"

MultiOverPlay.name = "MultiOverPlay"

MultiOverPlay.defaultValue = 2
MultiOverPlay.range = {2, 4}

MultiOverPlay.getString = function(self, config)
	return config.value .. "OP"
end

MultiOverPlay.apply = function(self, config)
	local noteChart = self.noteChartModel.noteChart
	local value = config.value

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
                local newInputIndex = (inputIndex - 1) * value + 1
				layerDataSequence:increaseInputCount(noteData.inputType, inputIndex, -1)
				layerDataSequence:increaseInputCount(noteData.inputType, newInputIndex, 1)
				noteData.inputIndex = newInputIndex
				for i = 1, value - 1 do
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
		noteChart.inputMode:setInputCount(inputType, inputCount * value)
	end

	noteChart:compute()
end

return MultiOverPlay
