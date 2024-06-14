local class = require("class")
local table_util = require("table_util")
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

	---@type {[ncdk2.Layer]: table}
	self.pointEvents = {}

	if self.eventBasedRender then
		for _, layer in pairs(self.chart.layers) do
			self.pointEvents[layer] = {}
			layer.visual:generateEvents()
		end
	end

	for notes, column, layer in self.chart:iterLayerNotes() do
		local noteDrawer = NoteDrawer(layer, notes, column, self)
		noteDrawer:load()
		table.insert(self.noteDrawers, noteDrawer)
	end
end

function GraphicEngine:unload()
	self.noteDrawers = {}
end

function GraphicEngine:update()
	local currentTime = self:getCurrentTime()

	local range = math.max(-self.range[1], self.range[2]) / self.visualTimeRate

	local pointEvents = self.pointEvents
	if self.eventBasedRender then
		for _, layer in pairs(self.chart.layers) do
			table_util.clear(pointEvents[layer])
			local scroller = layer.visual.scroller
			local function f(vp, action)
				table.insert(pointEvents[layer], {vp, action})
			end
			scroller:scroll(currentTime, f)
			scroller:scale(range, f)
		end
	end

	for _, noteDrawer in ipairs(self.noteDrawers) do
		noteDrawer.pointEvents = pointEvents[noteDrawer.layer]
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
