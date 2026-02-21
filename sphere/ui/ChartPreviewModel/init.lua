local class = require("class")
local ChartPreview = require("rizu.select.ChartPreview")

---@class sphere.ChartPreviewModel: rizu.select.ChartPreview
---@operator call: sphere.ChartPreviewModel
local ChartPreviewModel = ChartPreview + {}

function ChartPreviewModel:new(...)
	ChartPreview.new(self, ...)
	self.graphicEngine = self
end

return ChartPreviewModel
