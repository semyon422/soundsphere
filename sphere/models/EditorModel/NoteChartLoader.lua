local class = require("class")
local ConvertAbsoluteToInterval = require("sphere.models.EditorModel.ConvertAbsoluteToInterval")
local ConvertMeasureToInterval = require("sphere.models.EditorModel.ConvertMeasureToInterval")
local ConvertTests = require("sphere.models.EditorModel.ConvertTests")
local DynamicLayerData = require("ncdk.DynamicLayerData")

---@class sphere.EditorNoteChartLoader
---@operator call: sphere.EditorNoteChartLoader
local NoteChartLoader = class()

---@return ncdk.DynamicLayerData
function NoteChartLoader:load()
	local ld = self.editorModel.noteChart:getLayerData(1)

	if ld.mode == "absolute" then
		ld = ConvertAbsoluteToInterval(ld, "closest_gte")
	elseif ld.mode == "measure" then
		ld = ConvertMeasureToInterval(ld)
	end

	ld = DynamicLayerData(ld)

	return ld
end

function NoteChartLoader:save()
	self.editorModel.layerData:save(self.editorModel.noteChart:getLayerData(1))
end

return NoteChartLoader
