local Class					= require("aqua.util.Class")
local AnimationNoteView		= require("sphere.views.RhythmView.AnimationNoteView")

local AnimationNoteViewFactory = Class:new()

AnimationNoteViewFactory.getNoteView = function(self, graphicalNote)
	local noteView = {graphicalNote = graphicalNote}
	local noteData = graphicalNote.startNoteData
	noteView.startNoteData = graphicalNote.startNoteData
	noteView.endNoteData = graphicalNote.endNoteData

	if noteData.noteType == "ShortNote" then
		noteView.noteType = "ShortNoteAnimation"
		return AnimationNoteView:new(noteView)
	elseif noteData.noteType == "LongNoteStart" then
		noteView.noteType = "LongNoteAnimation"
		return AnimationNoteView:new(noteView)
	elseif noteData.noteType == "LaserNoteStart" then
		noteView.noteType = "LongNoteAnimation"
		return AnimationNoteView:new(noteView)
	end
end

return AnimationNoteViewFactory
