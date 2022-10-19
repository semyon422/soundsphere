local Class					= require("Class")
local FileFinder			= require("sphere.filesystem.FileFinder")
local ShortNoteView	= require("sphere.views.RhythmView.ShortNoteView")
local LongNoteView		= require("sphere.views.RhythmView.LongNoteView")
local ImageNoteView				= require("sphere.views.RhythmView.ImageNoteView")
local VideoNoteView				= require("sphere.views.RhythmView.VideoNoteView")

local NoteViewFactory = Class:new()

NoteViewFactory.notes = {
	default = {
		ShortNote = {"ShortNote", ShortNoteView},
		SoundNote = {"SoundNote", ShortNoteView},
		LongNoteStart = {"LongNote", LongNoteView},
		LaserNoteStart = {"LongNote", LongNoteView},
		LineNoteStart = {"LongNote", LongNoteView},
	},
	animation = {
		ShortNote = {"ShortNoteAnimation", ShortNoteView},
		LongNoteStart = {"LongNoteAnimation", ShortNoteView},
		LaserNoteStart = {"LongNoteAnimation", ShortNoteView},
	},
	lighting = {
		ShortNote = {"ShortNoteLighting", ShortNoteView},
		LongNoteStart = {"LongNoteLighting", ShortNoteView},
		LaserNoteStart = {"LongNoteLighting", ShortNoteView},
	},
	bga = {
		ImageNote = true,
	},
}

local function getNoteView(noteView, noteType)
	noteView.noteType = noteType
	return noteView
end

NoteViewFactory.getNoteView = function(self, graphicalNote)
	local noteData = graphicalNote.startNoteData

	local notes = self.notes[self.mode or "default"]
	local config = notes[noteData.noteType]
	if not config then
		return
	end

	if type(config) == "table" then
		return getNoteView(config[2], config[1])
	end

	local fileType
	local images = noteData.images[1] and noteData.images[1][1]
	if images then
		fileType = FileFinder:getType(images)
	end
	if fileType == "image" and self.bga.image then
		return getNoteView(ImageNoteView, "ImageNote")
	elseif fileType == "video" and self.bga.video then
		return getNoteView(VideoNoteView, "VideoNote")
	end
end

return NoteViewFactory
