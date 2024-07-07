local class = require("class")
local AbsoluteInterval = require("ncdk2.convert.AbsoluteInterval")
local MeasureInterval = require("ncdk2.convert.MeasureInterval")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local MeasureLayer = require("ncdk2.layers.MeasureLayer")
local Converter = require("chartedit.Converter")

---@class sphere.EditorNoteChartLoader
---@operator call: sphere.EditorNoteChartLoader
local NoteChartLoader = class()

---@return chartedit.Layer
function NoteChartLoader:load()
	local layer = self.editorModel.chart.layers.main

	if AbsoluteLayer * layer then
		local conv = AbsoluteInterval({1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 16}, 0.002)
		conv:convert(layer, "closest_gte")
	elseif MeasureLayer * layer then
		local conv = MeasureInterval()
		conv:convert(layer)
	end

	return Converter:load(layer)
end

function NoteChartLoader:save()
	self.editorModel.chart.layers.main = Converter:save(self.editorModel.layer)
end

return NoteChartLoader
