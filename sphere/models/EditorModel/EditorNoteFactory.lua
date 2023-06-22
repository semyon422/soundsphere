local Class = require("Class")
local ShortEditorNote = require("sphere.models.EditorModel.ShortEditorNote")
local LongEditorNote = require("sphere.models.EditorModel.LongEditorNote")

local EditorNoteFactory = Class:new()

local notes = {
	ShortNote = {ShortEditorNote, "ShortNote"},
	LongNoteStart = {LongEditorNote, "LongNote"},
	LaserNoteStart = {LongEditorNote, "LongNote"},
	LineNoteStart = {LongEditorNote, "LongNote"},
	SoundNote = {ShortEditorNote, "SoundNote"},
}

EditorNoteFactory.getNote = function(self, noteData)
	local classAndType = notes[noteData.noteType]
	if not classAndType then
		return
	end

	return classAndType[1]:new({
		noteType = classAndType[2],
		startNoteData = noteData,
	})
end

EditorNoteFactory.newNote = function(self, noteType)
	local classAndType = notes[noteType]
	if not classAndType then
		return
	end

	return classAndType[1]:new({
		noteType = classAndType[2],
	})
end

return EditorNoteFactory
