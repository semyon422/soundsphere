local class = require("class")
local ShortEditorNote = require("sphere.models.EditorModel.ShortEditorNote")
local LongEditorNote = require("sphere.models.EditorModel.LongEditorNote")

local EditorNoteFactory = class()

local notes = {
	ShortNote = {ShortEditorNote, "ShortNote"},
	LongNoteStart = {LongEditorNote, "LongNote"},
	LaserNoteStart = {LongEditorNote, "LongNote"},
	LineNoteStart = {LongEditorNote, "LongNote"},
	SoundNote = {ShortEditorNote, "SoundNote"},
}

function EditorNoteFactory:getNote(noteData)
	local classAndType = notes[noteData.noteType]
	if not classAndType then
		return
	end

	return classAndType[1](classAndType[2], noteData)
end

function EditorNoteFactory:newNote(noteType)
	local classAndType = notes[noteType]
	if not classAndType then
		return
	end

	return classAndType[1](classAndType[2], noteData)
end

return EditorNoteFactory
