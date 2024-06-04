local class = require("class")
local AbsoluteInterval = require("ncdk2.convert.AbsoluteInterval")
local MeasureInterval = require("ncdk2.convert.MeasureInterval")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local MeasureLayer = require("ncdk2.layers.MeasureLayer")
local Converter = require("chartedit.Converter")
local DynamicLayerData = require("ncdk.DynamicLayerData")

---@class sphere.EditorNoteChartLoader
---@operator call: sphere.EditorNoteChartLoader
local NoteChartLoader = class()

---@return chartedit.Layer
function NoteChartLoader:load()
	local ld = self.editorModel.noteChart.layers.main

	if AbsoluteLayer * ld then
		local conv = AbsoluteInterval({1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 16}, 0.002)
		conv:convert(ld, "closest_gte")
	elseif MeasureLayer * ld then
		local conv = MeasureInterval()
		conv:convert(ld)
	end

	return Converter:load(ld)
end

function NoteChartLoader:save()
	self.editorModel.noteChart.layers.main = Converter:save(self.editorModel.layerData)
end

return NoteChartLoader
