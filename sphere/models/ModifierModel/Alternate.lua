local Modifier	= require("sphere.models.ModifierModel.Modifier")

local Alternate = Modifier:new()

Alternate.type = "NoteChartModifier"

Alternate.name = "Alternate"
Alternate.shortName = "Alt"

Alternate.variableValues = {"key", "scratch"}
Alternate.modeNames = {"K", "S"}

Alternate.defaultValue = 1
Alternate.range = {1, 2}

Alternate.getString = function(self)
	return self.shortName .. self.modeNames[self.value]
end

Alternate.getRealValue = function(self, config)
	config = config or self.config
	return self.variableValues[config.value]
end

Alternate.apply = function(self)
	local noteChart = self.noteChartModel.noteChart

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
	local inputType = self.variableValues[self.value]
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
