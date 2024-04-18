local RhythmView = require("sphere.views.RhythmView")

---@class sphere.ChartPreviewRhythmView: sphere.RhythmView
---@operator call: sphere.ChartPreviewRhythmView
local ChartPreviewRhythmView = RhythmView + {}

---@param f function
function ChartPreviewRhythmView:processNotes(f)
	local chartPreviewModel = self.game.chartPreviewModel
	for _, graphicalNote in ipairs(chartPreviewModel.notes) do
		f(self, graphicalNote)
	end
end

return ChartPreviewRhythmView
