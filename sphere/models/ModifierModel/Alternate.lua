local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.Alternate: sphere.Modifier
---@operator call: sphere.Alternate
local Alternate = Modifier + {}

Alternate.interfaceType = "stepper"

Alternate.name = "Alternate"

Alternate.defaultValue = "key"
Alternate.range = {1, 2}
Alternate.values = {"key", "scratch"}

Alternate.description = "1 1 1 1 -> 1 2 1 2, doubles the input mode"

---@param config table
---@return string
function Alternate:getString(config)
	return "Alt"
end

---@param config table
---@return string
function Alternate:getSubString(config)
	return config.value:sub(1, 1):upper()
end

function Alternate:applyMeta(config, state)
	local inputType = config.value
	local inputMode = state.inputMode
	if not inputMode[inputType] then
		return
	end
	inputMode[inputType] = inputMode[inputType] * 2
end

---@param config table
function Alternate:apply(config)
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

						if inputAlternate[inputIndex] == 0 then
							newInputIndex = (inputIndex - 1) * 2 + 1
							inputAlternate[inputIndex] = 1
						elseif inputAlternate[inputIndex] == 1 then
							newInputIndex = (inputIndex - 1) * 2 + 2
							inputAlternate[inputIndex] = 0
						end
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

return Alternate
