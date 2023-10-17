local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.NoLongNote: sphere.Modifier
---@operator call: sphere.NoLongNote
local NoLongNote = Modifier + {}

NoLongNote.name = "NoLongNote"
NoLongNote.shortName = "NLN"

NoLongNote.description = "Remove long notes"

---@param config table
function NoLongNote:apply(config)
	local noteChart = self.noteChart

	for noteDatas in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			if noteData.noteType == "LongNoteStart" or noteData.noteType == "LaserNoteStart" then
				noteData.noteType = "ShortNote"
			elseif noteData.noteType == "LongNoteEnd" or noteData.noteType == "LaserNoteEnd" then
				noteData.noteType = "Ignore"
			end
		end
	end
end

return NoLongNote
