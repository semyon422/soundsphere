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
---@return chartedit.Notes
function NoteChartLoader:load()
	local chart = self.editorModel.chart
	local layer = chart.layers.main

	if AbsoluteLayer * layer then
		local conv = AbsoluteInterval({1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 16}, 0.002)
		conv:convert(layer, "closest_gte")
	elseif MeasureLayer * layer then
		local conv = MeasureInterval()
		conv:convert(layer)
	end

	local layers, notes = Converter:load(chart)
	return layers.main, notes
end

function NoteChartLoader:save()
	local chart = Converter:save({main = self.editorModel.layer}, self.editorModel.notes)
	self.editorModel.chart.layers.main = chart.layers.main
	self.editorModel.chart.notes = chart.notes
end

return NoteChartLoader
