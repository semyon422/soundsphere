local NoteData	= require("ncdk.NoteData")
local Modifier	= require("sphere.models.ModifierModel.Modifier")

local MultiOverPlay = Modifier:new()

MultiOverPlay.type = "NoteChartModifier"
MultiOverPlay.interfaceType = "stepper"

MultiOverPlay.name = "MultiOverPlay"

MultiOverPlay.defaultValue = 2
MultiOverPlay.range = {2, 4}

MultiOverPlay.description = "1 2 1 2 -> 12 34 12 34, doubles the input mode"

MultiOverPlay.getString = function(self, config)
	if config.old then
		return config.value + 1
	end
	return config.value
end

MultiOverPlay.getSubString = function(self, config)
	return "OP"
end

MultiOverPlay.applyMeta = function(self, config, state)
	local inputCounts = {}
	for inputType, inputCount in pairs(state.inputMode) do
		if inputCount > 0 then
			inputCounts[inputType] = inputCount
		end
	end

	local value = config.value
	if config.old then
		value = value + 1
	end
	for inputType, inputCount in pairs(inputCounts) do
		state.inputMode[inputType] = inputCount * value
	end
end

MultiOverPlay.apply = function(self, config)
	local noteChart = self.game.noteChartModel.noteChart
	local value = config.value
	if config.old then
		value = value + 1
	end

	local inputCounts = {}
	for inputType, inputIndex in noteChart:getInputIteraator() do
		if not inputCounts[inputType] then
			local inputCount = noteChart.inputMode[inputType]
			if inputCount then
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
		noteChart.inputMode[inputType] = inputCount * value
	end

	noteChart:compute()
end

return MultiOverPlay
