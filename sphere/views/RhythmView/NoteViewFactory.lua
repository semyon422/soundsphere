local Class					= require("Class")
local ShortNoteView	= require("sphere.views.RhythmView.ShortNoteView")
local LongNoteView		= require("sphere.views.RhythmView.LongNoteView")
local ImageNoteView				= require("sphere.views.RhythmView.ImageNoteView")
local VideoNoteView				= require("sphere.views.RhythmView.VideoNoteView")

local NoteViewFactory = Class:new()

NoteViewFactory.notes = {
	default = {
		ShortNote = {"ShortNote", ShortNoteView},
		SoundNote = {"SoundNote", ShortNoteView},
		LongNote = {"LongNote", LongNoteView},
	},
	animation = {
		ShortNote = {"ShortNoteAnimation", ShortNoteView},
		LongNote = {"LongNoteAnimation", ShortNoteView},
		LaserNote = {"LongNoteAnimation", ShortNoteView},
	},
	lighting = {
		ShortNote = {"ShortNoteLighting", ShortNoteView},
		LongNote = {"LongNoteLighting", ShortNoteView},
		LaserNote = {"LongNoteLighting", ShortNoteView},
	},
	bga = {
		ImageNote = {"ImageNote", ImageNoteView},
		VideoNote = {"VideoNote", VideoNoteView},
	},
}

local function getNoteView(noteView, noteType)
	noteView.noteType = noteType
	return noteView
end

NoteViewFactory.getNoteView = function(self, graphicalNote)
	local notes = self.notes[self.mode or "default"]
	local config = notes[graphicalNote.noteType]
	if config then
		return getNoteView(config[2], config[1])
	end
end

return NoteViewFactory
