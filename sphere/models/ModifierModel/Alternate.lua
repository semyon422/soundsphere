local Modifier	= require("sphere.models.ModifierModel.Modifier")

local Alternate = Modifier:new()

Alternate.type = "NoteChartModifier"
Alternate.interfaceType = "stepper"

Alternate.name = "Alternate"

Alternate.defaultValue = "key"
Alternate.range = {1, 2}
Alternate.values = {"key", "scratch"}

Alternate.description = "1 1 1 1 -> 1 2 1 2, doubles the input mode"

Alternate.getString = function(self, config)
	return "Alt"
end

Alternate.getSubString = function(self, config)
	return config.value:sub(1, 1):upper()
end

Alternate.apply = function(self, config)
	local noteChart = self.game.noteChartModel.noteChart

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
	local inputType = config.value
	local inputAlternate = {}

	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)

		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			local inputCount = inputCounts[noteData.inputType]
			local inputIndex = noteData.inputIndex
			if inputCount and noteData.inputType == inputType and (noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart") then
				inputAlternate[inputIndex] = inputAlternate[inputIndex] or 0

				local newInputIndex
				if inputAlternate[inputIndex] == 0 then
					newInputIndex = (inputIndex - 1) * 2 + 1
					inputAlternate[inputIndex] = 1
				elseif inputAlternate[inputIndex] == 1 then
					newInputIndex = (inputIndex - 1) * 2 + 2
					inputAlternate[inputIndex] = 0
				end

				layerDataSequence:increaseInputCount(noteData.inputType, noteData.inputIndex, -1)
				layerDataSequence:increaseInputCount(noteData.inputType, newInputIndex, 1)
				noteData.inputIndex = newInputIndex
			end
		end
	end

	noteChart.inputMode:setInputCount(inputType, inputCounts[inputType] * 2)

	noteChart:compute()
end

return Alternate
