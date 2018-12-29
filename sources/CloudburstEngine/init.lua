CloudburstEngine = createClass(soul.SoulObject)

require("CloudburstEngine.NoteHandler")
require("CloudburstEngine.NoteDrawer")

require("CloudburstEngine.note")

require("CloudburstEngine.NoteSkin")
require("CloudburstEngine.TimeManager")

CloudburstEngine.focus = "CloudburstEngine"
CloudburstEngine.autoplay = false

CloudburstEngine.load = function(self)
	soul.focus[self.focus] = true
	self.inputMode = self.noteChart.inputMode
	
	self.sharedLogicalNoteData = {}
	self.soundFiles = {}
	
	self:loadNoteHandlers()
	if self.noteSkin then
		self:loadNoteDrawers()
	end
	self:loadTimeManager()
	
	self:loadResources()
end

CloudburstEngine.update = function(self)
	self:updateTimeManager()
	if self.noteSkin then
		self:updateNoteDrawers()
	end
	if not self.resourcesLoaded then
		self:checkResources()
	end
end

CloudburstEngine.unload = function(self)
	soul.focus[self.focus] = nil
	self:unloadTimeManager()
	self:unloadNoteHandlers()
	if self.noteSkin then
		self:unloadNoteDrawers()
	end
	
	self:unloadResources()
end

CloudburstEngine.receiveEvent = function(self, event)
	if event.name == "love.update" then
		self:update()
	elseif soul.focus[self.focus] and event.name == "love.keypressed" then
		local key = event.data[1]
		if key == "return" then
			self.timeManager:play()
		elseif key == "f1" then
			self.timeManager:pause()
		elseif key == "f3" then
			if CloudburstEngine.NoteSkin.speed - 0.1 >= 0.1 then
				CloudburstEngine.NoteSkin.speed = CloudburstEngine.NoteSkin.speed - 0.1
			end
		elseif key == "f4" then
			CloudburstEngine.NoteSkin.speed = CloudburstEngine.NoteSkin.speed + 0.1
		elseif key == "f8" then
			self.autoplay = not self.autoplay
		
			self:sendEvent({
				name = "notify",
				text = "autoplay: " .. (self.autoplay and "on" or "off")
			})
		elseif key == "escape" then
			self.core.stateManager:switchState("selectionScreen")
		end
	elseif event.name == "resourcesLoaded" then
		self.timeManager:play()
	elseif event.name == "ChunkDataLoaded" and self.loadingResources[event.filePath] then
		self.loadingResources[event.filePath] = nil
		self.resourceCountLoaded = self.resourceCountLoaded + 1
		
		self:sendEvent({
			name = "notify",
			text = self.resourceCountLoaded .. "/" .. self.resourceCount
		})
	end
end

CloudburstEngine.loadResources = function(self)
	self.resourceCount = 0
	self.resourceCountLoaded = 0
	self.resourcesLoaded = false
	self.loadingResources = {}
	self.soundFilesGroup = Group:new()
	self.core.audioManager:addObserver(self.observer)
	
	for _, soundFilePath in pairs(self.soundFiles) do
		self.soundFilesGroup:addObject(soundFilePath)
		self.loadingResources[soundFilePath] = true
		self.resourceCount = self.resourceCount + 1
	end
	
	self.soundFilesGroup:call(function(soundFilePath)
		self.core.audioManager:loadChunk(soundFilePath)
	end)
end

CloudburstEngine.checkResources = function(self)
	for filePath in pairs(self.loadingResources) do
		return
	end
	self.resourcesLoaded = true
	self:receiveEvent({
		name = "resourcesLoaded"
	})
end

CloudburstEngine.unloadResources = function(self)
	self.core.audioManager:removeObserver(self.observer)
	
	self.soundFilesGroup:call(function(soundFilePath)
		self.core.audioManager:stopSound(soundFilePath)
	end)
	
	self.soundFilesGroup:call(function(soundFilePath)
		self.core.audioManager:unloadChunk(soundFilePath)
	end)
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
		local noteHandler = self.NoteHandler:new({
			inputType = inputType,
			inputIndex = inputIndex,
			engine = self
		})
		self.noteHandlers[noteHandler] = noteHandler
		self.noteHandlers[noteHandler]:activate()
	end
end

CloudburstEngine.unloadNoteHandlers = function(self)
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:deactivate()
	end
	self.noteHandlers = nil
end

CloudburstEngine.loadNoteDrawers = function(self)
	self.noteDrawers = {}
	
	for layerIndex in self.noteChart:getLayerDataIndexIterator() do
		local layerData = self.noteChart:requireLayerData(layerIndex)
		if not layerData.invisible then
			for inputType, inputIndex in self.noteChart:getInputIteraator() do
				local noteDrawer = self.NoteDrawer:new({
					layerIndex = layerIndex,
					inputType = inputType,
					inputIndex = inputIndex,
					engine = self
				})
				self.noteDrawers[noteDrawer] = noteDrawer
				self.noteDrawers[noteDrawer]:load()
			end
		end
	end
end

CloudburstEngine.updateNoteDrawers = function(self)
	for _, noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:update()
	end
end

CloudburstEngine.unloadNoteDrawers = function(self)
	for _, noteDrawer in pairs(self.noteDrawers) do
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