local class = require("class")
local NoteDrawer = require("sphere.models.RhythmModel.GraphicEngine.NoteDrawer")
local flux = require("flux")

local GraphicEngine = class()

GraphicEngine.visualOffset = 0
GraphicEngine.longNoteShortening = 0
GraphicEngine.scaleSpeed = false

function GraphicEngine:load()
	self.noteCount = 0
	self.noteDrawers = {}

	for noteDatas, inputType, inputIndex, layerDataIndex in self.noteChart:getInputIterator() do
		local noteDrawer = NoteDrawer({
			layerData = self.noteChart.layerDatas[layerDataIndex],
			noteDatas = noteDatas,
			inputType = inputType,
			inputIndex = inputIndex,
			graphicEngine = self
		})
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

function GraphicEngine:getVisualTimeRate()
	local timeRate = self.rhythmModel.timeEngine.timeRate
	local visualTimeRate = self.visualTimeRate
	if not self.scaleSpeed then
		visualTimeRate = visualTimeRate / timeRate
	end
	return visualTimeRate
end

function GraphicEngine:getCurrentTime()
	return self.rhythmModel.timeEngine.currentVisualTime
end

function GraphicEngine:getInputOffset()
	return self.rhythmModel.logicEngine.inputOffset
end

function GraphicEngine:getVisualOffset()
	return self.visualOffset
end

return GraphicEngine
