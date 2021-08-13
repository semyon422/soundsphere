local Class					= require("aqua.util.Class")
local FileManager			= require("sphere.filesystem.FileManager")
local ShortNoteView	= require("sphere.views.RhythmView.ShortNoteView")
local LongNoteView		= require("sphere.views.RhythmView.LongNoteView")
local ImageNoteView				= require("sphere.views.RhythmView.ImageNoteView")
local VideoNoteView				= require("sphere.views.RhythmView.VideoNoteView")

local NoteViewFactory = Class:new()

NoteViewFactory.getNoteView = function(self, graphicalNote)
	local noteView = {graphicalNote = graphicalNote}
	local noteData = graphicalNote.startNoteData
	noteView.startNoteData = graphicalNote.startNoteData
	noteView.endNoteData = graphicalNote.endNoteData

	if noteData.noteType == "ShortNote" then
		noteView.noteType = "ShortNote"
		return ShortNoteView:new(noteView)
	elseif noteData.noteType == "LongNoteStart" then
		noteView.noteType = "LongNote"
		return LongNoteView:new(noteView)
	elseif noteData.noteType == "LaserNoteStart" then
		noteView.noteType = "LongNote"
		return LongNoteView:new(noteView)
	elseif noteData.noteType == "LineNoteStart" then
		noteView.noteType = "LongNote"
		return LongNoteView:new(noteView)
	elseif noteData.noteType == "SoundNote" then
		noteView.noteType = "SoundNote"
		return ShortNoteView:new(noteView)
	elseif noteData.noteType == "ImageNoteView" then
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
end

return NoteViewFactory
