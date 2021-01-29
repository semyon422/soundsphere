local NoteData	= require("ncdk.NoteData")
local Modifier	= require("sphere.models.ModifierModel.Modifier")

local MultiplePlay = Modifier:new()

MultiplePlay.type = "NoteChartModifier"

MultiplePlay.name = "MultiplePlay"
MultiplePlay.shortName = "MP"

MultiplePlay.defaultValue = 1
MultiplePlay.format = "%s"
MultiplePlay.range = {1, 3}
MultiplePlay.values = {"DP", "TP", "QP"}

MultiplePlay.getString = function(self, config)
	config = config or self.config
	return self.values[config.value]
end

MultiplePlay.apply = function(self)
	local noteChart = self.noteChartModel.noteChart
	local value = self.config.value

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
