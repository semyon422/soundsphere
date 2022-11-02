local Modifier	= require("sphere.models.ModifierModel.Modifier")
local Alternate	= require("sphere.models.ModifierModel.Alternate")

local Alternate2 = Modifier:new()

Alternate2.type = "NoteChartModifier"
Alternate2.interfaceType = "stepper"

Alternate2.name = "Alternate2"

Alternate2.defaultValue = "key"
Alternate2.range = {1, 2}
Alternate2.values = {"key", "scratch"}

Alternate2.description = "1 1 1 1 -> 1 1 2 2, doubles the input mode"

Alternate2.getString = function(self, config)
	return "Alt"
end

Alternate2.getSubString = function(self, config)
	return "2" .. config.value:sub(1, 1):upper()
end

Alternate2.applyMeta = Alternate.applyMeta

Alternate2.apply = function(self, config)
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

                local state = inputAlternate[inputIndex]
                local plusColumn
				local newInputIndex
				if state == 0 then
                    plusColumn = 1
					state = 1
				elseif state == 1 then
                    plusColumn = 1
					state = 2
				elseif state == 2 then
                    plusColumn = 2
					state = 3
				elseif state == 3 then
                    plusColumn = 2
					state = 0
				end
                newInputIndex = (inputIndex - 1) * 2 + plusColumn
                inputAlternate[inputIndex] = state

				noteChart:increaseInputCount(noteData.inputType, noteData.inputIndex, -1)
				noteChart:increaseInputCount(noteData.inputType, newInputIndex, 1)
				noteData.inputIndex = newInputIndex
			end
		end
	end

	inputMode[inputType] = inputMode[inputType] * 2

	noteChart:compute()
end

return Alternate2
