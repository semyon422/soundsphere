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
	return config.value
end

MultiOverPlay.getSubString = function(self, config)
	return "OP"
end

MultiOverPlay.applyMeta = function(self, config, state)
	local inputMode = state.inputMode

	local value = config.value
	for inputType, inputCount in pairs(inputMode) do
		inputMode[inputType] = inputCount * value
	end
end

MultiOverPlay.apply = function(self, config)
	local noteChart = self.noteChart
	local value = config.value

	local inputMode = noteChart.inputMode

	for _, layerData in noteChart:getLayerDataIterator() do
		for inputType, r in pairs(layerData.noteDatas) do
			local inputCount = inputMode[inputType]
			if inputCount then
				local _r = {}
				for inputIndex, noteDatas in pairs(r) do
					for _, noteData in ipairs(noteDatas) do
						for i = 1, value do
							local newInputIndex = (inputIndex - 1) * value + i
							_r[newInputIndex] = _r[newInputIndex] or {}

							local newNoteData = NoteData:new(noteData.timePoint)

							newNoteData.endNoteData = noteData.endNoteData  -- fix wrong reference
							newNoteData.noteType = noteData.noteType
							newNoteData.sounds = noteData.sounds

							table.insert(_r[newInputIndex], newNoteData)
						end
					end
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
