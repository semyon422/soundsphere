CloudburstEngine = createClass(soul.SoulObject)

require("CloudburstEngine.NoteHandler")
require("CloudburstEngine.NoteDrawer")

require("CloudburstEngine.LogicalNote")
require("CloudburstEngine.ShortLogicalNote")
require("CloudburstEngine.LongLogicalNote")
require("CloudburstEngine.SoundNote")

require("CloudburstEngine.GraphicalNote")
require("CloudburstEngine.ShortGraphicalNote")
require("CloudburstEngine.LongGraphicalNote")

require("CloudburstEngine.NoteSkin")
require("CloudburstEngine.TimeManager")

require("CloudburstEngine.ResourceObserver")

CloudburstEngine.load = function(self)
	self.inputMode = self.core.inputModeLoader:getInputMode(self.noteChart.inputMode)
	
	self.sharedLogicalNoteData = {}
	self.soundFiles = {}
	
	self:loadNoteHandlers()
	self:loadNoteDrawers()
	self:loadTimeManager()
	
	self:loadResources()
	
	self:setCallbacks()
	
	self.loaded = true
end

CloudburstEngine.update = function(self)
	self:updateTimeManager()
	self:updateNoteHandlers()
	self:updateNoteDrawers()
end

CloudburstEngine.unload = function(self)
	self:unloadTimeManager()
	self:unloadNoteHandlers()
	self:unloadNoteDrawers()
	
	self:unloadResources()
	
	self:unsetCallbacks()
	
	self.loaded = false
end

CloudburstEngine.setCallbacks = function(self)
	soul.setCallback("keypressed", self, function(key)
		if key == "return" then
			self.timeManager:play()
			audioManager:playSoundGroup("engine")
		elseif key == "f1" then
			self.timeManager:pause()
			audioManager:pauseSoundGroup("engine")
		end
	end)
end

CloudburstEngine.unsetCallbacks = function(self)
	soul.unsetCallback("keypressed", self)
end

CloudburstEngine.loadResources = function(self)
	self.resourceObserver = self.ResourceObserver:new()
	self.resourceObserver.engine = self
	self.core.audioManager:addObserver(self.resourceObserver)
	
	for _, soundFilePath in pairs(self.soundFiles) do
		self.core.audioManager:loadChunk(soundFilePath, "engine")
	end
end

CloudburstEngine.unloadResources = function(self)
	self.core.audioManager:removeObserver(self.resourceObserver)
	
	self.core.audioManager:stopSoundGroup("engine")
	self.core.audioManager:unloadChunkGroup("engine")
end

CloudburstEngine.loadTimeManager = function(self)
	self.timeManager = self.TimeManager:new()
	self.timeManager.engine = self
	self.timeManager:load()
	self.currentTime = self.timeManager:getCurrentTime()
end

CloudburstEngine.updateTimeManager = function(self)
	self.timeManager:update()
	self.currentTime = self.timeManager:getCurrentTime()
end

CloudburstEngine.unloadTimeManager = function(self)
	self.timeManager:unload()
end

CloudburstEngine.loadNoteHandlers = function(self)
	self.noteHandlers = {}
	for inputType, inputIndex in self.noteChart:getInputIteraator() do
		local noteHandlerIndex = {inputType, inputIndex}
		self.noteHandlers[noteHandlerIndex] = self.NoteHandler:new({
			inputType = inputType,
			inputIndex = inputIndex,
			engine = self
		})
		self.noteHandlers[noteHandlerIndex]:load()
	end
end

CloudburstEngine.updateNoteHandlers = function(self)
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:update()
	end
end

CloudburstEngine.unloadNoteHandlers = function(self)
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:unload()
	end
	self.noteHandlers = nil
end

CloudburstEngine.loadNoteDrawers = function(self)
	self.noteDrawers = {}
	
	for layerIndex in self.noteChart:getLayerDataIndexIterator() do
		local layerData = self.noteChart:requireLayerData(layerIndex)
		
		if not layerData.invisible then
			self.noteDrawers[layerIndex] = self.NoteDrawer:new({
				layerIndex = layerIndex,
				engine = self
			})
			self.noteDrawers[layerIndex]:load()
		end
	end
end

CloudburstEngine.updateNoteDrawers = function(self)
	for layerIndex, noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:update()
	end
end

CloudburstEngine.unloadNoteDrawers = function(self)
	for layerIndex, noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:unload()
	end
	self.noteDrawers = nil
end

CloudburstEngine.judgeScores = {
	{0.016, 2},
	{0.048, 1},
	{0.128, 0},
	{0.160, 0}
}

CloudburstEngine.passEdge = CloudburstEngine.judgeScores[#CloudburstEngine.judgeScores - 1][1]
CloudburstEngine.missEdge = CloudburstEngine.judgeScores[#CloudburstEngine.judgeScores][1]
CloudburstEngine.getTimeState = function(self, deltaTime)
	if math.abs(deltaTime) - self.passEdge > 0 and math.abs(deltaTime) - self.missEdge <= 0 then
		if deltaTime > 0 then
			return "early"
		else
			return "late"
		end
	elseif math.abs(deltaTime) - self.passEdge <= 0 then
		return "exactly"
	elseif deltaTime + self.passEdge < 0 then
		return "late"
	else
		return "none"
	end
end

CloudburstEngine.getJudgeScore = function(self, deltaTime)
	for _, data in ipairs(self.judgeScores) do
		if math.abs(deltaTime) <= data[1] then
			return data[2]
		end
	end
end