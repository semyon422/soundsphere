local Class					= require("aqua.util.Class")
local FileManager			= require("sphere.filesystem.FileManager")
local ShortNoteView	= require("sphere.views.RhythmView.ShortNoteView")
local LongNoteView		= require("sphere.views.RhythmView.LongNoteView")
local LightingNoteView		= require("sphere.views.RhythmView.LightingNoteView")
local ImageNoteView				= require("sphere.views.RhythmView.ImageNoteView")
local VideoNoteView				= require("sphere.views.RhythmView.VideoNoteView")

local NoteViewFactory = Class:new()

NoteViewFactory.notes = {
	default = {
		ShortNote = {"ShortNote", ShortNoteView},
		LongNoteStart = {"LongNote", LongNoteView},
		LaserNoteStart = {"LongNote", LongNoteView},
		LineNoteStart = {"LongNote", LongNoteView},
		ImageNoteView = true,
	},
	animation = {
		ShortNote = {"ShortNoteAnimation", ShortNoteView},
		LongNoteStart = {"LongNoteAnimation", ShortNoteView},
		LaserNoteStart = {"LongNoteAnimation", ShortNoteView},
	},
	lighting = {
		ShortNote = {"ShortNoteLighting", LightingNoteView},
		LongNoteStart = {"LongNoteLighting", LightingNoteView},
		LaserNoteStart = {"LongNoteLighting", LightingNoteView},
	},
}

NoteViewFactory.mode = "default"

NoteViewFactory.getNoteView = function(self, graphicalNote)
	local noteView = {graphicalNote = graphicalNote}
	local noteData = graphicalNote.startNoteData
	noteView.startNoteData = graphicalNote.startNoteData
	noteView.endNoteData = graphicalNote.endNoteData

	local notes = self.notes[self.mode]
	local config = notes[noteData.noteType]
	if not config then
		return
	end

	if type(config) == "table" then
		noteView.noteType = config[1]
		return config[2]:new(noteView)
	end

	local fileType
	local images = noteData.images[1] and noteData.images[1][1]
	if images then
		fileType = FileManager:getType(images)
	end
	if fileType == "image" and self.imageBgaEnabled then
		noteView.noteType = "ImageNote"
		return ImageNoteView:new(noteView)
	elseif fileType == "video" and self.videoBgaEnabled then
		noteView.noteType = "VideoNote"
		return VideoNoteView:new(noteView)
	end
end

return NoteViewFactory
