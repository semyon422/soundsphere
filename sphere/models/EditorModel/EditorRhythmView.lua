local RhythmView = require("sphere.views.RhythmView")

local EditorRhythmView = RhythmView:new()

EditorRhythmView.fillChords = function(self)
	-- for _, noteDrawer in ipairs(self.game.rhythmModel.graphicEngine.noteDrawers) do
	-- 	for i = noteDrawer.endNoteIndex, noteDrawer.startNoteIndex, -1 do
	-- 		self:fillChord(noteDrawer.notes[i])
	-- 	end
	-- end
end

EditorRhythmView.drawNotes = function(self)
	-- for _, noteDrawer in ipairs(self.game.rhythmModel.graphicEngine.noteDrawers) do
	-- 	for i = noteDrawer.startNoteIndex, noteDrawer.endNoteIndex do
	-- 		self:drawNote(noteDrawer.notes[i])
	-- 	end
	-- end
end

return EditorRhythmView
