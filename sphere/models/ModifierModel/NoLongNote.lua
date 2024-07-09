local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.NoLongNote: sphere.Modifier
---@operator call: sphere.NoLongNote
local NoLongNote = Modifier + {}

NoLongNote.name = "NoLongNote"
NoLongNote.shortName = "NLN"

NoLongNote.description = "Remove long notes"

---@param config table
---@param chart ncdk2.Chart
function NoLongNote:apply(config, chart)
	for _, note in chart.notes:iter() do
		if note.noteType == "LongNoteStart" or note.noteType == "LaserNoteStart" then
			note.noteType = "ShortNote"
			note.endNote = nil
		elseif note.noteType == "LongNoteEnd" or note.noteType == "LaserNoteEnd" then
			note.noteType = "Ignore"
			note.startNote = nil
		end
	end
end

return NoLongNote
