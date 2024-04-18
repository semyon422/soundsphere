local RhythmView = require("sphere.views.RhythmView")

---@class sphere.ChartPreviewRhythmView: sphere.RhythmView
---@operator call: sphere.ChartPreviewRhythmView
local ChartPreviewRhythmView = RhythmView + {}

---@param f function
function ChartPreviewRhythmView:processNotes(f)
	local graphicEngine = self.game.chartPreviewModel.graphicEngine
	for _, noteDrawer in ipairs(graphicEngine.noteDrawers) do
		for i = noteDrawer.startNoteIndex, noteDrawer.endNoteIndex do
			f(self, noteDrawer.notes[i])
		end
	end
end

return ChartPreviewRhythmView
