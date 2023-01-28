local NoteData	= require("ncdk.NoteData")
local Modifier	= require("sphere.models.ModifierModel.Modifier")
local MultiOverPlay	= require("sphere.models.ModifierModel.MultiOverPlay")

local MultiplePlay = Modifier:new()

MultiplePlay.type = "NoteChartModifier"

MultiplePlay.name = "MultiplePlay"
MultiplePlay.interfaceType = "stepper"

MultiplePlay.defaultValue = 2
MultiplePlay.range = {2, 4}

MultiplePlay.description = "1 2 1 2 -> 13 24 13 24, doubles the input mode"

MultiplePlay.getString = function(self, config)
	if config.old then
		return config.value + 1
	end
	return config.value
end

MultiplePlay.getSubString = function(self, config)
	return "P"
end

MultiplePlay.applyMeta = MultiOverPlay.applyMeta

MultiplePlay.apply = function(self, config)
	local noteChart = self.game.noteChartModel.noteChart
	local value = config.value
	if config.old then
		value = value + 1
	end

	local inputMode = noteChart.inputMode

	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		local layerData = noteChart.layerDatas[layerDataIndex]
		for _, noteData in ipairs(noteDatas) do
			local inputCount = inputMode[inputType]
			if inputCount then
				for i = 1, value - 1 do
					local newInputIndex = inputIndex + inputCount * i

					local newNoteData = NoteData:new(noteData.timePoint)

					newNoteData.endNoteData = noteData.endNoteData
					newNoteData.noteType = noteData.noteType
					newNoteData.sounds = noteData.sounds

					layerData:addNoteData(newNoteData, inputType, newInputIndex)
				end
			end
		end
	end

	for inputType, inputCount in pairs(inputMode) do
		inputMode[inputType] = inputCount * value
	end

	noteChart:compute()
end

return MultiplePlay
