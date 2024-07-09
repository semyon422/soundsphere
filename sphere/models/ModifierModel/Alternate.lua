local Modifier = require("sphere.models.ModifierModel.Modifier")
local InputMode = require("ncdk.InputMode")
local Notes = require("ncdk2.notes.Notes")

---@class sphere.Alternate: sphere.Modifier
---@operator call: sphere.Alternate
local Alternate = Modifier + {}

Alternate.name = "Alternate"

Alternate.defaultValue = "key"
Alternate.values = {"key", "scratch"}

Alternate.description = "1 1 1 1 -> 1 2 1 2, doubles the input mode"

---@param config table
---@return string
---@return string
function Alternate:getString(config)
	return "Alt", config.value:sub(1, 1):upper()
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
---@param chart ncdk2.Chart
function Alternate:apply(config, chart)
	local inputMode = chart.inputMode

	local inputType = config.value
	if not inputMode[inputType] then
		return
	end

	---@type number[]
	local inputAlternate = {}

	local new_notes = Notes()
	for _, note in chart.notes:iter() do
		local _inputType, inputIndex = InputMode:splitInput(note.column)
		if _inputType ~= inputType then
			new_notes:insert(note)
		elseif _inputType and inputIndex then
			inputAlternate[inputIndex] = inputAlternate[inputIndex] or 1

			local isStartNote = note.noteType == "ShortNote" or note.noteType == "LongNoteStart"
			if isStartNote then
				inputAlternate[inputIndex] = math.abs(inputAlternate[inputIndex] - 1)
			end

			local newInputIndex = (inputIndex - 1) * 2 + 1 + inputAlternate[inputIndex]

			local column = _inputType .. newInputIndex
			if note.noteType == "ShortNote" then
				note.column = column
				new_notes:insert(note)
			elseif note.noteType == "LongNoteStart" then
				note.column = column
				note.endNote.column = column
				new_notes:insert(note)
				new_notes:insert(note.endNote)
			end
		end
	end
	chart.notes = new_notes

	inputMode[inputType] = inputMode[inputType] * 2

	chart:compute()
end

return Alternate
