local Note = require("ncdk2.notes.Note")
local Notes = require("ncdk2.notes.Notes")
local InputMode = require("ncdk.InputMode")
local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.MultiOverPlay: sphere.Modifier
---@operator call: sphere.MultiOverPlay
local MultiOverPlay = Modifier + {}

MultiOverPlay.name = "MultiOverPlay"

MultiOverPlay.defaultValue = 2
MultiOverPlay.values = {2, 3, 4}

MultiOverPlay.description = "1 2 1 2 -> 12 34 12 34, doubles the input mode"

---@param config table
---@return string
---@return string
function MultiOverPlay:getString(config)
	return tostring(config.value), "OP"
end

---@param config table
---@param state table
function MultiOverPlay:applyMeta(config, state)
	local inputMode = state.inputMode

	local value = config.value
	for inputType, inputCount in pairs(inputMode) do
		inputMode[inputType] = inputCount * value
	end
end

---@param config table
---@param chart ncdk2.Chart
function MultiOverPlay:apply(config, chart)
	local value = config.value

	local inputMode = chart.inputMode

	for _, layer in pairs(chart.layers) do
		local new_notes = Notes()
		for column, notes in layer.notes:iter() do
			local inputType, inputIndex = InputMode:splitInput(column)
			local inputCount = inputMode[inputType]
			if inputCount then
				for _, note in ipairs(notes) do
					for i = 1, value do
						local newInputIndex = (inputIndex - 1) * value + i

						local newNote = Note(note.visualPoint)

						newNote.endNote = note.endNote  -- fix wrong reference
						newNote.noteType = note.noteType
						newNote.sounds = note.sounds

						new_notes:insert(newNote, inputType .. newInputIndex)
					end
				end
			end
		end
		layer.notes = new_notes
	end

	for inputType, inputCount in pairs(inputMode) do
		inputMode[inputType] = inputCount * value
	end

	chart:compute()
end

return MultiOverPlay
