local Modifier = require("sphere.models.ModifierModel.Modifier")
local InputMode = require("ncdk.InputMode")

---@class sphere.NoScratch: sphere.Modifier
---@operator call: sphere.NoScratch
local NoScratch = Modifier + {}

NoScratch.name = "NoScratch"
NoScratch.shortName = "NSC"

NoScratch.description = "Remove scratch notes"

---@param config table
---@param state table
function NoScratch:applyMeta(config, state)
	state.inputMode.scratch = nil
end

---@param config table
---@param chart ncdk2.Chart
function NoScratch:apply(config, chart)
	chart.inputMode.scratch = nil

	for _, layer in pairs(chart.layers) do
		for column, notes in layer.notes:iter() do
			local inputType, inputIndex = InputMode:splitInput(column)
			if inputType == "scratch" then
				for _, note in ipairs(notes) do
					note.noteType = "SoundNote"
					layer.notes:insert(note, "auto" .. inputIndex)
				end
				layer.notes.column_notes[column] = nil
			end
		end
	end
end

return NoScratch
