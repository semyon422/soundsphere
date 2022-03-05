local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local NoteDrawer		= require("sphere.models.RhythmModel.GraphicEngine.NoteDrawer")
local tween = require("tween")

local GraphicEngine = Class:new()

GraphicEngine.construct = function(self)
	self.observable = Observable:new()

	self.localAliases = {}
	self.globalAliases = {}

	self.noteDrawers = {}
end

GraphicEngine.load = function(self)
	self.noteCount = 0

	self:loadNoteDrawers()
end

GraphicEngine.update = function(self, dt)
	if self.visualTimeRateTween and self.updateTween then
		self.visualTimeRateTween:update(dt)
	end
	self:updateNoteDrawers()
end

GraphicEngine.increaseVisualTimeRate = function(self, delta)
	if math.abs(self.targetVisualTimeRate + delta) > 0.001 then
		self.targetVisualTimeRate = self.targetVisualTimeRate + delta
		self:setVisualTimeRate(self.targetVisualTimeRate)
	else
		self.targetVisualTimeRate = 0
		self:setVisualTimeRate(self.targetVisualTimeRate)
	end
end

GraphicEngine.setVisualTimeRate = function(self, visualTimeRate)
	if visualTimeRate * self.visualTimeRate < 0 then
		self.visualTimeRate = visualTimeRate
		self.updateTween = false
	else
		self.updateTween = true
		self.visualTimeRateTween = tween.new(0.25, self, {visualTimeRate = visualTimeRate}, "inOutQuad")
	end
end

GraphicEngine.getVisualTimeRate = function(self)
	return self.visualTimeRate / math.abs(self.rhythmModel.timeEngine.timeRate)
end

GraphicEngine.unload = function(self)
	self:unloadNoteDrawers()
end

GraphicEngine.receive = function(self, event)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:receive(event)
	end
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
	for layerIndex in self.noteChart:getLayerDataIndexIterator() do
		local layerData = self.noteChart:requireLayerData(layerIndex)
		if not layerData.invisible then
			for inputType, inputIndex in self.noteChart:getInputIteraator() do
				local noteDrawer = self:getNoteDrawer(layerIndex, inputType, inputIndex)
				if noteDrawer then
					self.noteDrawers[noteDrawer] = noteDrawer
					noteDrawer:load()
				end
			end
		end
	end
end

GraphicEngine.updateNoteDrawers = function(self)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:update()
	end
end

GraphicEngine.unloadNoteDrawers = function(self)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:unload()
	end
	self.noteDrawers = {}
end

return GraphicEngine
