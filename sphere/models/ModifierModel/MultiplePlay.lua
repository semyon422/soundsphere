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

	for _, layerData in noteChart:getLayerDataIterator() do
		for inputType, r in pairs(layerData.noteDatas) do
			local inputCount = inputMode[inputType]
			if inputCount then
				local _r = {}
				for inputIndex, noteDatas in pairs(r) do
					for _, noteData in ipairs(noteDatas) do
						for i = 1, value do
							local newInputIndex = inputIndex + inputCount * (i - 1)
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

return MultiplePlay
