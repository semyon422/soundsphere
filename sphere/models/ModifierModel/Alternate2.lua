local Modifier = require("sphere.models.ModifierModel.Modifier")
local Alternate = require("sphere.models.ModifierModel.Alternate")
local InputMode = require("ncdk.InputMode")
local Notes = require("ncdk2.notes.Notes")

---@class sphere.Alternate2: sphere.Modifier
---@operator call: sphere.Alternate2
local Alternate2 = Modifier + {}

Alternate2.name = "Alternate2"

Alternate2.defaultValue = "key"
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
---@param chart ncdk2.Chart
function Alternate2:apply(config, chart)
	local inputMode = chart.inputMode

	local inputType = config.value
	if not inputMode[inputType] then
		return
	end

	---@type number[]
	local inputAlternate = {}

	for _, layer in pairs(chart.layers) do
		local new_notes = Notes()
		for column, notes in layer.notes:iter() do
			for _, note in ipairs(notes) do
				local _inputType, inputIndex = InputMode:splitInput(column)
				if _inputType ~= inputType then
					new_notes:insert(note, column)
				elseif _inputType and inputIndex then
					local newInputIndex = inputIndex
					local isStartNote = note.noteType == "ShortNote" or note.noteType == "LongNoteStart"
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

					new_notes:insert(note, _inputType .. newInputIndex)
				end
			end
		end
		layer.notes = new_notes
	end

	inputMode[inputType] = inputMode[inputType] * 2

	chart:compute()
end

return Alternate2
