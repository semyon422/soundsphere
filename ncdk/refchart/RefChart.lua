local class = require("class")
local Layer = require("refchart.Layer")
local Note = require("refchart.Note")

---@class refchart.RefChart
---@operator call: refchart.RefChart
---@field inputmode ncdk.InputMode
---@field layers {[string]: refchart.Layer}
---@field notes refchart.Note[]
---@field resources string[][]
local RefChart = class()

---@param chart ncdk2.Chart
function RefChart:new(chart)
	self.inputmode = chart.inputMode

	---@type {[ncdk2.VisualPoint]: refchart.VisualPointReference}
	local vp_ref = {}

	self.layers = {}
	local layers = self.layers
	for l_name, layer in pairs(chart.layers) do
		layers[l_name] = Layer(layer, l_name, vp_ref)
	end

	self.notes = {}
	local notes = self.notes
	for i, note in ipairs(chart.notes.notes) do
		notes[i] = Note(note, vp_ref[note.visualPoint])
	end

	self.resources = {}
	local resources = self.resources
	for _type, paths in chart.resources:iter() do
		table.insert(resources, {_type, unpack(paths)})
	end
end

return RefChart
