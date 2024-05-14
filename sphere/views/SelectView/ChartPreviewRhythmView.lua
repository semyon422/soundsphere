local RhythmView = require("sphere.views.RhythmView")

---@class sphere.ChartPreviewRhythmView: sphere.RhythmView
---@operator call: sphere.ChartPreviewRhythmView
local ChartPreviewRhythmView = RhythmView + {}

---@param f function
function ChartPreviewRhythmView:processNotes(f)
	local graphicEngine = self.game.chartPreviewModel.graphicEngine
	for _, noteDrawer in ipairs(graphicEngine.noteDrawers) do
		if graphicEngine.eventBasedRender then
			for _, note in ipairs(noteDrawer.visibleNotesList) do
				f(self, note)
			end
		else
			for i = noteDrawer.startNoteIndex, noteDrawer.endNoteIndex do
				f(self, noteDrawer.notes[i])
			end
		end
	end
end

return ChartPreviewRhythmView
