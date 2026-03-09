local RhythmView = require("sphere.views.RhythmView")

---@class sphere.ChartPreviewRhythmView: sphere.RhythmView
---@operator call: sphere.ChartPreviewRhythmView
---@field chartPreview rizu.preview.NotesPreviewPlayer
local ChartPreviewRhythmView = RhythmView + {}

---@param f function
function ChartPreviewRhythmView:processNotes(f)
	local graphicEngine = self.chartPreview.graphicEngine
	graphicEngine:iterNotes(f, self)
end

---@return sphere.NoteSkin
function ChartPreviewRhythmView:getNoteSkin()
	return self.chartPreview.noteSkin
end

return ChartPreviewRhythmView
