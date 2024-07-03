local Note = require("ncdk2.notes.Note")
local Notes = require("ncdk2.notes.Notes")
local InputMode = require("ncdk.InputMode")
local Modifier = require("sphere.models.ModifierModel.Modifier")
local MultiOverPlay = require("sphere.models.ModifierModel.MultiOverPlay")

---@class sphere.MultiplePlay: sphere.Modifier
---@operator call: sphere.MultiplePlay
local MultiplePlay = Modifier + {}

MultiplePlay.name = "MultiplePlay"

MultiplePlay.defaultValue = 2
MultiplePlay.values = {2, 3, 4}

MultiplePlay.description = "1 2 1 2 -> 13 24 13 24, doubles the input mode"

---@param config table
---@return string
---@return string
function MultiplePlay:getString(config)
	return tostring(config.value), "P"
end

MultiplePlay.applyMeta = MultiOverPlay.applyMeta

---@param config table
---@param chart ncdk2.Chart
function MultiplePlay:apply(config, chart)
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
						local newInputIndex = inputIndex + inputCount * (i - 1)
						if note.startNote then
						elseif note.endNote then
							local startNote = Note(note.visualPoint)
							local endNote = Note(note.endNote.visualPoint)

							startNote.endNote = endNote
							endNote.startNote = startNote

							startNote.noteType = note.noteType
							startNote.sounds = note.sounds
							endNote.noteType = note.endNote.noteType
							endNote.sounds = note.endNote.sounds

							new_notes:insert(startNote, inputType .. newInputIndex)
							new_notes:insert(endNote, inputType .. newInputIndex)
						else
							local newNote = Note(note.visualPoint)
							newNote.noteType = note.noteType
							newNote.sounds = note.sounds
							new_notes:insert(newNote, inputType .. newInputIndex)
						end
					end
				end
			else
				for _, note in ipairs(notes) do
					new_notes:insert(note, column)
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

return MultiplePlay
