local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.NoLongNote: sphere.Modifier
---@operator call: sphere.NoLongNote
local NoLongNote = Modifier + {}

NoLongNote.defaultValue = true
NoLongNote.name = "NoLongNote"
NoLongNote.shortName = "NLN"
NoLongNote.values = {false, true}

NoLongNote.description = "Remove long notes"

---@param config table
---@return string?
---@return string?
function NoLongNote:getString(config)
	if not config.value then
		return
	end
	return Modifier.getString(self, config)
end

---@param config table
function NoLongNote:apply(config)
	if not config.value then
		return
	end

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
