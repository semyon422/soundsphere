local class = require("class")
local ColumnRenderer = require("sphere.models.RhythmModel.GraphicEngine.ColumnRenderer")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")

---@class sphere.ColumnsRenderer
---@operator call: sphere.ColumnsRenderer
local ColumnsRenderer = class()

---@param chart ncdk2.Chart
---@param graphicEngine sphere.GraphicEngine
function ColumnsRenderer:new(chart, graphicEngine)
	self.chart = chart
	self.graphicEngine = graphicEngine
end

function ColumnsRenderer:load()
	---@type {[ncdk2.Visual]: integer}
	self.cvpi = {}
	---@type {[ncdk2.Visual]: ncdk2.VisualPoint}
	self.cvp = {}

	for _, visual in ipairs(self.chart:getVisuals()) do
		self.cvpi[visual] = 1
		self.cvp[visual] = VisualPoint(Point())
	end

	---@type {[ncdk2.Column]: sphere.ColumnRenderer}
	self.columnRenderers = {}
	for column, notes in pairs(self.chart.notes:getColumnNotes()) do
		local columnRenderer = ColumnRenderer(notes, column, self)
		columnRenderer:load()
		self.columnRenderers[column] = columnRenderer
	end
end

function ColumnsRenderer:update()
	local graphicEngine = self.graphicEngine
	local currentTime = graphicEngine:getCurrentTime()

	for _, visual in ipairs(self.chart:getVisuals()) do
		local cvp = self.cvp[visual]
		cvp.point.absoluteTime = currentTime - graphicEngine:getInputOffset()
		self.cvpi[visual] = visual.interpolator:interpolate(
			visual.points, self.cvpi[visual], cvp, "absolute"
		)
	end

	for _, columnRenderer in pairs(self.columnRenderers) do
		columnRenderer:update()
	end
end

---@generic T
---@param f fun(obj: T, note: sphere.GraphicalNote)
---@param obj T
function ColumnsRenderer:iterNotes(f, obj)
	for _, columnRenderer in pairs(self.columnRenderers) do
		for i = columnRenderer.startNoteIndex, columnRenderer.endNoteIndex do
			f(obj, columnRenderer.notes[i])
		end
	end
end

return ColumnsRenderer
