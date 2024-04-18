local class = require("class")

---@class sphere.PreviewGraphicEngine
---@operator call: sphere.PreviewGraphicEngine
local PreviewGraphicEngine = class()

---@param previewModel sphere.PreviewModel
function PreviewGraphicEngine:new(previewModel)
	self.previewModel = previewModel
	self.notes = {}
end

PreviewGraphicEngine.longNoteShortening = 0

---@return number
function PreviewGraphicEngine:getCurrentTime()
	return self.previewModel:getTime()
end

---@return number
function PreviewGraphicEngine:getInputOffset()
	return 0
end

---@return number
function PreviewGraphicEngine:getVisualOffset()
	return 0
end

---@return number
function PreviewGraphicEngine:getVisualTimeRate()
	return 1
end

return PreviewGraphicEngine
