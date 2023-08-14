local class = require("class")
local ConvertAbsoluteToInterval = require("sphere.models.EditorModel.ConvertAbsoluteToInterval")
local ConvertMeasureToInterval = require("sphere.models.EditorModel.ConvertMeasureToInterval")
local ConvertTests = require("sphere.models.EditorModel.ConvertTests")
local DynamicLayerData = require("ncdk.DynamicLayerData")

local NoteChartLoader = class()

function NoteChartLoader:load()
	local ld = self.editorModel.noteChart:getLayerData(1)

	if ld.mode == "absolute" then
		ld = ConvertAbsoluteToInterval(ld)
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
