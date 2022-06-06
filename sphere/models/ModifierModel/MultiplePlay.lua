local NoteData	= require("ncdk.NoteData")
local Modifier	= require("sphere.models.ModifierModel.Modifier")

local MultiplePlay = Modifier:new()

MultiplePlay.type = "NoteChartModifier"

MultiplePlay.name = "MultiplePlay"
MultiplePlay.interfaceType = "stepper"

MultiplePlay.defaultValue = 2
MultiplePlay.range = {2, 4}

MultiplePlay.getString = function(self, config)
	if config.old then
		return config.value + 1
	end
	return config.value
end

MultiplePlay.getSubString = function(self, config)
	return "P"
end

MultiplePlay.apply = function(self, config)
	local noteChart = self.game.noteChartModel.noteChart
	local value = config.value
	if config.old then
		value = value + 1
	end

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
				for i = 1, value - 1 do
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
		noteChart.inputMode:setInputCount(inputType, inputCount * value)
	end

	noteChart:compute()
end

return MultiplePlay
