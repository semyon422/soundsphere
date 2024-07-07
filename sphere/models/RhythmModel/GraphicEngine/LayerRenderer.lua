local class = require("class")
local table_util = require("table_util")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")
local ColumnRenderer = require("sphere.models.RhythmModel.GraphicEngine.ColumnRenderer")

---@class sphere.LayerRenderer
---@operator call: sphere.LayerRenderer
local LayerRenderer = class()

---@param graphicEngine sphere.GraphicEngine
---@param layer ncdk2.Layer
function LayerRenderer:new(graphicEngine, layer)
	self.graphicEngine = graphicEngine
	self.layer = layer
	self.pointEvents = {}

	self.currentVisualPointIndex = 1
	self.currentVisualPoint = VisualPoint(Point())

	---@type {[ncdk2.Column]: sphere.ColumnRenderer}
	self.columnRenderers = {}
	for column, notes in layer.notes:iter() do
		self.columnRenderers[column] = ColumnRenderer(layer, notes, column, self)
	end
end

function LayerRenderer:load()
	local layer = self.layer

	if self.graphicEngine.eventBasedRender then
		layer.visual:generateEvents()
	end

	for _, columnRenderer in pairs(self.columnRenderers) do
		columnRenderer:load()
	end
end

function LayerRenderer:update()
	local graphicEngine = self.graphicEngine
	local cvp = self.currentVisualPoint
	local currentTime = graphicEngine:getCurrentTime()
	cvp.point.absoluteTime = currentTime - graphicEngine:getInputOffset()

	local interpolator = self.layer.visual.interpolator
	local visualPoints = self.layer.visual.points

	self.currentVisualPointIndex = interpolator:interpolate(
		visualPoints, self.currentVisualPointIndex, cvp, "absolute"
	)

	local visualTimeRate = graphicEngine.visualTimeRate * cvp.globalSpeed
	local range = math.max(-graphicEngine.range[1], graphicEngine.range[2]) / visualTimeRate

	local pointEvents = self.pointEvents
	if graphicEngine.eventBasedRender then
		table_util.clear(pointEvents)
		local scroller = self.layer.visual.scroller
		local function f(vp, action)
			table.insert(pointEvents, {vp, action})
		end
		scroller:scroll(currentTime, f)
		scroller:scale(range, f)
	end

	for _, columnRenderer in pairs(self.columnRenderers) do
		columnRenderer.pointEvents = pointEvents
		columnRenderer:update()
	end
end

return LayerRenderer
