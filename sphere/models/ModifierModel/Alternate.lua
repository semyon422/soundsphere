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

Alternate.applyMeta = function(self, config, state)
	local inputType = config.value
	local inputMode = state.inputMode
	if not inputMode[inputType] then
		return
	end
	inputMode[inputType] = inputMode[inputType] * 2
end

Alternate.apply = function(self, config)
	local noteChart = self.game.noteChartModel.noteChart

	local inputMode = noteChart.inputMode

	local inputType = config.value
	if not inputMode[inputType] then
		return
	end

	local inputAlternate = {}

	for _, layerData in noteChart:getLayerDataIterator() do
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			local inputIndex = noteData.inputIndex
			local isStartNote = noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart"
			if noteData.inputType == inputType and isStartNote then
				inputAlternate[inputIndex] = inputAlternate[inputIndex] or 0

				local newInputIndex
				if inputAlternate[inputIndex] == 0 then
					newInputIndex = (inputIndex - 1) * 2 + 1
					inputAlternate[inputIndex] = 1
				elseif inputAlternate[inputIndex] == 1 then
					newInputIndex = (inputIndex - 1) * 2 + 2
					inputAlternate[inputIndex] = 0
				end

				noteChart:increaseInputCount(noteData.inputType, noteData.inputIndex, -1)
				noteChart:increaseInputCount(noteData.inputType, newInputIndex, 1)
				noteData.inputIndex = newInputIndex
			end
		end
	end

	inputMode[inputType] = inputMode[inputType] * 2

	noteChart:compute()
end

return Alternate
