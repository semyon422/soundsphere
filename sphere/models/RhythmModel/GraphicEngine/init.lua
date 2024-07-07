local class = require("class")
local LayerRenderer = require("sphere.models.RhythmModel.GraphicEngine.LayerRenderer")
local flux = require("flux")

---@class sphere.GraphicEngine
---@operator call: sphere.GraphicEngine
local GraphicEngine = class()

GraphicEngine.visualOffset = 0
GraphicEngine.longNoteShortening = 0
GraphicEngine.scaleSpeed = false
GraphicEngine.constant = false
GraphicEngine.eventBasedRender = false
GraphicEngine.range = {-1, 1}

---@param visualTimeInfo sphere.VisualTimeInfo
---@param logicEngine sphere.LogicEngine?
function GraphicEngine:new(visualTimeInfo, logicEngine)
	self.visualTimeInfo = visualTimeInfo
	self.logicEngine = logicEngine
	self.layerRenderers = {}
end

---@param chart ncdk2.Chart
function GraphicEngine:setChart(chart)
	self.chart = chart
end

function GraphicEngine:load()
	self.notes_count = 0

	---@type {[string]: sphere.LayerRenderer}
	self.layerRenderers = {}

	for name, layer in pairs(self.chart.layers) do
		local layerRenderer = LayerRenderer(self, layer)
		layerRenderer:load()
		self.layerRenderers[name] = layerRenderer
	end
end

function GraphicEngine:unload()
	self.layerRenderers = {}
end

function GraphicEngine:update()
	for _, layerRenderer in pairs(self.layerRenderers) do
		layerRenderer:update()
	end
end

---@generic T
---@param f fun(obj: T, note: sphere.GraphicalNote)
---@param obj T
function GraphicEngine:iterNotes(f, obj)
	local eventBasedRender = self.eventBasedRender
	for _, layerRenderer in pairs(self.layerRenderers) do
		for _, columnRenderer in pairs(layerRenderer.columnRenderers) do
			if eventBasedRender then
				for _, note in ipairs(columnRenderer.visibleNotesList) do
					f(obj, note)
				end
			else
				for i = columnRenderer.startNoteIndex, columnRenderer.endNoteIndex do
					f(obj, columnRenderer.notes[i])
				end
			end
		end
	end
end

function GraphicEngine:setVisualTimeRate(visualTimeRate)
	if math.abs(visualTimeRate) <= 0.001 then
		visualTimeRate = 0
	end
	self.targetVisualTimeRate = visualTimeRate
	if self.tween then
		self.tween:stop()
	end
	if visualTimeRate * self.visualTimeRate < 0 then
		self.visualTimeRate = visualTimeRate
	else
		self.tween = flux.to(self, 0.25, {visualTimeRate = visualTimeRate}):ease("quadinout")
	end
end

---@return number
function GraphicEngine:getVisualTimeRate()
	local timeRate = self.visualTimeInfo.rate
	local visualTimeRate = self.visualTimeRate
	if not self.scaleSpeed then
		visualTimeRate = visualTimeRate / timeRate
	end
	return visualTimeRate
end

---@return number
function GraphicEngine:getCurrentTime()
	return self.visualTimeInfo.time
end

---@return number
function GraphicEngine:getInputOffset()
	local logicEngine = self.logicEngine
	return logicEngine and logicEngine.inputOffset or 0
end

---@param note notechart.Note
---@return sphere.LogicalNote?
function GraphicEngine:getLogicalNote(note)
	local logicEngine = self.logicEngine
	return logicEngine and logicEngine:getLogicalNote(note)
end

---@return number
function GraphicEngine:getVisualOffset()
	return self.visualOffset
end

return GraphicEngine
