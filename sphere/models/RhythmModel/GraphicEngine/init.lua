local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local NoteDrawer		= require("sphere.models.RhythmModel.GraphicEngine.NoteDrawer")

local GraphicEngine = Class:new()

GraphicEngine.construct = function(self)
	self.observable = Observable:new()

	self.localAliases = {}
	self.globalAliases = {}

	self.noteDrawers = {}
end

GraphicEngine.load = function(self)
	self.noteCount = 0
	self.currentTime = 0
	self.timeRate = 1

	self:loadNoteDrawers()
end

GraphicEngine.update = function(self, dt)
	self:updateNoteDrawers()

	self.noteSkin:update(dt)
end

GraphicEngine.unload = function(self)
	self:unloadNoteDrawers()
end

GraphicEngine.receive = function(self, event)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:receive(event)
	end

	if event.name == "TimeState" then
		self.currentTime = event.currentTime
		self.timeRate = event.timeRate
		if self.noteSkin and event.timeRate ~= 0 then
			self.noteSkin.timeRate = event.timeRate
		end
		return
	end
end

GraphicEngine.getLogicalNote = function(self, noteData)
	return self.logicEngine.sharedLogicalNotes[noteData]
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

GraphicEngine.reloadNoteDrawers = function(self)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:reload()
	end
end

return GraphicEngine
