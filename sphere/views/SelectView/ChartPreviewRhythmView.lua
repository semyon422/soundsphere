local RhythmView = require("sphere.views.RhythmView")

---@class sphere.ChartPreviewRhythmView: sphere.RhythmView
---@operator call: sphere.ChartPreviewRhythmView
local ChartPreviewRhythmView = RhythmView + {}

---@param f function
function ChartPreviewRhythmView:processNotes(f)
	local graphicEngine = self.game.chartPreviewModel.graphicEngine
	graphicEngine:iterNotes(f, self)
end

return ChartPreviewRhythmView
