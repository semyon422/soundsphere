local class = require("class")
local NoteDrawer = require("sphere.models.RhythmModel.GraphicEngine.NoteDrawer")
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
end

---@param chart ncdk2.Chart
function GraphicEngine:setChart(chart)
	self.chart = chart
end

function GraphicEngine:load()
	self.notes_count = 0

	---@type sphere.NoteDrawer[]
	self.noteDrawers = {}

	local range = {
		self.range[1] / self.visualTimeRate,
		self.range[2] / self.visualTimeRate,
	}

	if self.eventBasedRender then
		for _, layer in pairs(self.chart.layers) do
			layer.visual:generateEvents(range)
		end
	end

	for notes, column, layerName in self.chart:getNotesIterator() do
		local layer = self.chart.layers[layerName]
		local noteDrawer = NoteDrawer(layer, notes, column, self)
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
