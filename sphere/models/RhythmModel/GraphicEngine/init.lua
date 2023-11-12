local class = require("class")
local NoteDrawer = require("sphere.models.RhythmModel.GraphicEngine.NoteDrawer")
local TimeToEvent = require("sphere.models.RhythmModel.GraphicEngine.TimeToEvent")
local flux = require("flux")

---@class sphere.GraphicEngine
---@operator call: sphere.GraphicEngine
local GraphicEngine = class()

GraphicEngine.visualOffset = 0
GraphicEngine.longNoteShortening = 0
GraphicEngine.scaleSpeed = false
GraphicEngine.constant = false
GraphicEngine.eventBasedRender = false

---@param timeEngine sphere.TimeEngine
---@param logicEngine sphere.LogicEngine
function GraphicEngine:new(timeEngine, logicEngine)
	self.timeEngine = timeEngine
	self.logicEngine = logicEngine
end

function GraphicEngine:load()
	self.noteCount = 0
	self.noteDrawers = {}

	local layerEvents = {}

	local eventRange = 1 / self.visualTimeRate

	for noteDatas, inputType, inputIndex, layerDataIndex in self.noteChart:getInputIterator() do
		local layerData = self.noteChart.layerDatas[layerDataIndex]
		local noteDrawer = NoteDrawer({
			layerData = layerData,
			noteDatas = noteDatas,
			inputType = inputType,
			inputIndex = inputIndex,
			graphicEngine = self
		})
		if self.eventBasedRender then
			layerEvents[layerDataIndex] = layerEvents[layerDataIndex] or TimeToEvent(layerData, eventRange)
			noteDrawer.events = layerEvents[layerDataIndex]
		end
		noteDrawer:load()
		table.insert(self.noteDrawers, noteDrawer)
	end
end

function GraphicEngine:unload()
	self.noteDrawers = {}
end

function GraphicEngine:update()
	for _, noteDrawer in ipairs(self.noteDrawers) do
		noteDrawer:update()
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
	local timeRate = self.timeEngine.timeRate
	local visualTimeRate = self.visualTimeRate
	if not self.scaleSpeed then
		visualTimeRate = visualTimeRate / timeRate
	end
	return visualTimeRate
end

---@return number
function GraphicEngine:getCurrentTime()
	return self.timeEngine.currentVisualTime
end

---@return number
function GraphicEngine:getInputOffset()
	return self.logicEngine.inputOffset
end

---@return number
function GraphicEngine:getVisualOffset()
	return self.visualOffset
end

return GraphicEngine
