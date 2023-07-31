local Class				= require("Class")
local NoteDrawer		= require("sphere.models.RhythmModel.GraphicEngine.NoteDrawer")
local flux = require("flux")

local GraphicEngine = Class:new()

GraphicEngine.visualOffset = 0
GraphicEngine.scaleSpeed = false

GraphicEngine.load = function(self)
	self.noteCount = 0
	self.noteDrawers = {}

	for noteDatas, inputType, inputIndex, layerDataIndex in self.noteChart:getInputIterator() do
		local noteDrawer = NoteDrawer:new({
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

GraphicEngine.unload = function(self)
	self.noteDrawers = {}
end

GraphicEngine.update = function(self)
	for _, noteDrawer in ipairs(self.noteDrawers) do
		noteDrawer:update()
	end
end

GraphicEngine.setVisualTimeRate = function(self, visualTimeRate)
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

GraphicEngine.getVisualTimeRate = function(self)
	local timeRate = self.rhythmModel.timeEngine.timeRate
	local visualTimeRate = self.visualTimeRate
	if not self.scaleSpeed then
		visualTimeRate = visualTimeRate / timeRate
	end
	return visualTimeRate
end

GraphicEngine.getCurrentTime = function(self)
	return self.rhythmModel.timeEngine.currentVisualTime
end

GraphicEngine.getInputOffset = function(self)
	return self.rhythmModel.logicEngine.inputOffset
end

GraphicEngine.getVisualOffset = function(self)
	return self.visualOffset
end

return GraphicEngine
