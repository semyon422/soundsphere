local Class				= require("Class")
local Observable		= require("Observable")
local NoteDrawer		= require("sphere.models.RhythmModel.GraphicEngine.NoteDrawer")
local flux = require("flux")

local GraphicEngine = Class:new()

GraphicEngine.construct = function(self)
	self.observable = Observable:new()

	self.noteDrawers = {}
	self.scaleSpeed = false
	self.loaded = false
end

GraphicEngine.load = function(self)
	self.noteCount = 0

	self:loadNoteDrawers()
end

GraphicEngine.update = function(self, dt)
	for _, noteDrawer in ipairs(self.noteDrawers) do
		noteDrawer:update()
	end
end

GraphicEngine.increaseVisualTimeRate = function(self, delta)
	local target = self.targetVisualTimeRate
	local newTarget = math.floor((target + delta) / delta + 0.5) * delta

	if math.abs(newTarget) > 0.001 then
		self.targetVisualTimeRate = newTarget
		self:setVisualTimeRate(self.targetVisualTimeRate)
	else
		self.targetVisualTimeRate = 0
		self:setVisualTimeRate(self.targetVisualTimeRate)
	end
end

GraphicEngine.setVisualTimeRate = function(self, visualTimeRate)
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
	local visualTimeRate = self.visualTimeRate / math.abs(self.rhythmModel.timeEngine.timeRate)
	if self.scaleSpeed then
		visualTimeRate = visualTimeRate * self.rhythmModel.timeEngine.timeRate
	end
	return visualTimeRate
end

GraphicEngine.unload = function(self)
	self.loaded = false
	for _, noteDrawer in ipairs(self.noteDrawers) do
		noteDrawer:unload()
	end
	self.noteDrawers = {}
end

GraphicEngine.getLogicalNote = function(self, noteData)
	return self.rhythmModel.logicEngine.sharedLogicalNotes[noteData]
end

GraphicEngine.getNoteDrawer = function(self, layerIndex, inputType, inputIndex)
	return NoteDrawer:new({
		layerIndex = layerIndex,
		inputType = inputType,
		inputIndex = inputIndex,
		graphicEngine = self
	})
end

GraphicEngine.loadNoteDrawers = function(self)
	assert(not self.loaded)
	self.loaded = true
	for layerIndex in self.noteChart:getLayerDataIndexIterator() do
		local layerData = self.noteChart:requireLayerData(layerIndex)
		if not layerData.invisible then
			for inputType, inputIndex in self.noteChart:getInputIteraator() do
				local noteDrawer = self:getNoteDrawer(layerIndex, inputType, inputIndex)
				if noteDrawer then
					table.insert(self.noteDrawers, noteDrawer)
					noteDrawer:load()
				end
			end
		end
	end
end

return GraphicEngine
