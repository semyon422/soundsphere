local class = require("class")
local Chart = require("ncdk2.Chart")
local AbsoluteLayer = require("ncdk2.layers.AbsoluteLayer")
local MeasureLayer = require("ncdk2.layers.MeasureLayer")
local IntervalLayer = require("ncdk2.layers.IntervalLayer")
local Visual = require("ncdk2.visual.Visual")
local Note = require("ncdk2.notes.Note")

---@class notechart.ChartBuilder
---@operator call: notechart.ChartBuilder
local ChartBuilder = class()

function ChartBuilder:new()
	self.chart = Chart()
end

---@return ncdk2.AbsoluteLayer
function ChartBuilder:createAbsoluteLayer()
	local layer = AbsoluteLayer()
	self.chart.layers.main = layer
	return layer
end

---@return ncdk2.MeasureLayer
function ChartBuilder:createMeasureLayer()
	local layer = MeasureLayer()
	self.chart.layers.main = layer
	return layer
end

---@return ncdk2.IntervalLayer
function ChartBuilder:createIntervalLayer()
	local layer = IntervalLayer()
	self.chart.layers.main = layer
	return layer
end

---@return ncdk2.Layer
function ChartBuilder:getMainLayer()
	return self.chart.layers.main
end

---@param name string
function ChartBuilder:getVisual(name)
	local layer = self:getMainLayer()
	local visual = layer.visuals[name]
	if visual then
		return visual
	end

	visual = Visual()
	layer.visuals[name] = visual

	return visual
end

---@param file_name string
---@param offset number?
---@param volume number?
function ChartBuilder:setMainAudio(file_name, offset, volume)
	local chart = self.chart

	local layer = AbsoluteLayer()
	chart.layers.audio = layer

	local visual = Visual()
	layer.visuals.main = visual

	local vp = visual:getPoint(layer:getPoint(offset or 0))

	local note = Note(vp, "audio", "sample")
	note.data = {sounds = {{file_name, volume or 1}}}
	chart.resources:add("sound", file_name)

	chart.notes:insert(note)
end

return ChartBuilder
