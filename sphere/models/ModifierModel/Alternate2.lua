local Modifier = require("sphere.models.ModifierModel.Modifier")
local Alternate = require("sphere.models.ModifierModel.Alternate")

---@class sphere.Alternate2: sphere.Modifier
---@operator call: sphere.Alternate2
local Alternate2 = Modifier + {}

Alternate2.interfaceType = "stepper"

Alternate2.name = "Alternate2"

Alternate2.defaultValue = "key"
Alternate2.range = {1, 2}
Alternate2.values = {"key", "scratch"}

Alternate2.description = "1 1 1 1 -> 1 1 2 2, doubles the input mode"

---@param config table
---@return string
---@return string
function Alternate2:getString(config)
	return "Alt", "2" .. config.value:sub(1, 1):upper()
end

Alternate2.applyMeta = Alternate.applyMeta

---@param config table
function Alternate2:apply(config)
	local noteChart = self.noteChart

	local inputMode = noteChart.inputMode

	local inputType = config.value
	if not inputMode[inputType] then
		return
	end

	local inputAlternate = {}

	for _, layerData in noteChart:getLayerDataIterator() do
		if layerData.noteDatas[inputType] then
			local notes = {}
			for inputIndex, noteDatas in pairs(layerData.noteDatas[inputType]) do
				local newInputIndex = inputIndex
				for _, noteData in ipairs(noteDatas) do
					local isStartNote = noteData.noteType == "ShortNote" or noteData.noteType == "LongNoteStart"
					if isStartNote then
						inputAlternate[inputIndex] = inputAlternate[inputIndex] or 0

						local state = inputAlternate[inputIndex]
						local plusColumn
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
					end

					notes[newInputIndex] = notes[newInputIndex] or {}
					table.insert(notes[newInputIndex], noteData)
				end
			end
			layerData.noteDatas[inputType] = notes
		end
	end

	inputMode[inputType] = inputMode[inputType] * 2

	noteChart:compute()
end

return Alternate2
