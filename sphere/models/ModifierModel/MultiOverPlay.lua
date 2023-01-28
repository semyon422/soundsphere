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
	local inputMode = state.inputMode

	local value = config.value
	if config.old then
		value = value + 1
	end
	for inputType, inputCount in pairs(inputMode) do
		inputMode[inputType] = inputCount * value
	end
end

MultiOverPlay.apply = function(self, config)
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

	for _, layerData in noteChart:getLayerDataIterator() do
		for inputType, r in pairs(layerData.noteDatas) do
			local inputCount = inputMode[inputType]
			if inputCount then
				local _r = {}
				for inputIndex, noteDatas in pairs(r) do
					local c = math.floor((inputIndex - 1) / inputCount) + 1
					local d = (inputIndex - 1) % inputCount
					_r[d * value + c] = noteDatas
				end
				layerData.noteDatas[inputType] = _r
			end
		end
	end

	for inputType, inputCount in pairs(inputMode) do
		inputMode[inputType] = inputCount * value
	end

	noteChart:compute()
end

return MultiOverPlay
