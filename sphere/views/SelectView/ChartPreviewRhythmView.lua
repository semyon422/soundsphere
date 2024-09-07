local RhythmView = require("sphere.views.RhythmView")

---@class sphere.ChartPreviewRhythmView: sphere.RhythmView
---@operator call: sphere.ChartPreviewRhythmView
---@field chartPreviewModel sphere.ChartPreviewModel
local ChartPreviewRhythmView = RhythmView + {}

---@param f function
function ChartPreviewRhythmView:processNotes(f)
	local graphicEngine = self.chartPreviewModel.graphicEngine
	graphicEngine:iterNotes(f, self)
end

---@return sphere.NoteSkin
function ChartPreviewRhythmView:getNoteSkin()
	return self.chartPreviewModel.noteSkin
end

return ChartPreviewRhythmView
