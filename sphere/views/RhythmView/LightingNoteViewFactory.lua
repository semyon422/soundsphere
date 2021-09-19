local Class					= require("aqua.util.Class")
local LightingNoteView		= require("sphere.views.RhythmView.LightingNoteView")

local LightingNoteViewFactory = Class:new()

LightingNoteViewFactory.getNoteView = function(self, graphicalNote)
	local noteView = {graphicalNote = graphicalNote}
	local noteData = graphicalNote.startNoteData
	noteView.startNoteData = graphicalNote.startNoteData
	noteView.endNoteData = graphicalNote.endNoteData

	if noteData.noteType == "ShortNote" then
		noteView.noteType = "ShortNoteLighting"
		return LightingNoteView:new(noteView)
	elseif noteData.noteType == "LongNoteStart" then
		noteView.noteType = "LongNoteLighting"
		return LightingNoteView:new(noteView)
	elseif noteData.noteType == "LaserNoteStart" then
		noteView.noteType = "LongNoteLighting"
		return LightingNoteView:new(noteView)
	end
end

return LightingNoteViewFactory
