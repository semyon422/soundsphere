local class = require("class")
local ShortEditorNote = require("sphere.models.EditorModel.ShortEditorNote")
local LongEditorNote = require("sphere.models.EditorModel.LongEditorNote")

---@class sphere.EditorNoteFactory
---@operator call: sphere.EditorNoteFactory
local EditorNoteFactory = class()

local notes = {
	ShortNote = {ShortEditorNote, "ShortNote"},
	LongNoteStart = {LongEditorNote, "LongNote"},
	LaserNoteStart = {LongEditorNote, "LongNote"},
	LineNoteStart = {LongEditorNote, "LongNote"},
	SoundNote = {ShortEditorNote, "SoundNote"},
}

---@param noteType string
---@return sphere.EditorNote?
function EditorNoteFactory:newNote(noteType)
	local classAndType = notes[noteType]
	if not classAndType then
		return
	end

	return classAndType[1](classAndType[2])
end

return EditorNoteFactory
