local Container = require("aqua.graphics.Container")
local Class = require("aqua.util.Class")
local Group = require("aqua.util.Group")
local Observable = require("aqua.util.Observable")
local AudioManager = require("aqua.audio.AudioManager")
local sound = require("aqua.sound")

local CloudburstEngine = Class:new()

local NoteHandler = require("sphere.game.CloudburstEngine.NoteHandler")
local NoteDrawer = require("sphere.game.CloudburstEngine.NoteDrawer")

local NoteSkin = require("sphere.game.CloudburstEngine.NoteSkin")
local Score = require("sphere.game.CloudburstEngine.Score")
local TimeManager = require("sphere.game.CloudburstEngine.TimeManager")

CloudburstEngine.autoplay = false

CloudburstEngine.load = function(self)
	self.observable = Observable:new()
	
	self.inputMode = self.noteChart.inputMode
	
	self.sharedLogicalNoteData = {}
	self.soundFiles = {}
	
	self:loadNoteHandlers()
	self:loadNoteDrawers()
	self:loadTimeManager()
	
	self:loadResources()
	
	self.noteSkin.allcs:reload()
	self.noteSkin.cs:reload()
end

CloudburstEngine.update = function(self)
	self:updateTimeManager()
	self:updateNoteHandlers()
	self:updateNoteDrawers()
	if not self.resourcesLoaded then
		self:checkResources()
	end
end

CloudburstEngine.unload = function(self)
	self:unloadTimeManager()
	self:unloadNoteHandlers()
	self:unloadNoteDrawers()
	
	self:unloadResources()
end

CloudburstEngine.receive = function(self, event)
	for noteHandler in pairs(self.noteHandlers) do
		noteHandler:receive(event)
	end
	
	if event.name == "resize" then
		self.noteSkin.allcs:reload()
		self.noteSkin.cs:reload()
		self:reloadNoteDrawers()
	elseif event.name == "keypressed" then
		local key = event.args[1]
		if key == "return" then
			return self.timeManager:play()
		elseif key == "f1" then
			return self.timeManager:pause()
		elseif key == "f3" then
			if NoteSkin.speed - 0.1 >= 0.1 then
				NoteSkin.speed = NoteSkin.speed - 0.1
				return self.observable:send({
					name = "notify",
					text = "speed: " .. NoteSkin.speed
				})
			end
		elseif key == "f4" then
			NoteSkin.speed = NoteSkin.speed + 0.1
			return self.observable:send({
				name = "notify",
				text = "speed: " .. NoteSkin.speed
			})
		elseif key == "f8" then
			self.autoplay = not self.autoplay
			return self.observable:send({
				name = "notify",
				text = "autoplay: " .. (self.autoplay and "on" or "off")
			})
		end
	end
end

CloudburstEngine.loadResources = function(self)
	self.resourceCount = 0
	self.resourceCountLoaded = 0
	self.resourcesLoaded = false
	self.loadingResources = {}
	self.soundFilesGroup = Group:new()
	
	for _, soundFilePath in pairs(self.soundFiles) do
		self.soundFilesGroup:add(soundFilePath)
		self.loadingResources[soundFilePath] = true
		self.resourceCount = self.resourceCount + 1
	end
	
	self.soundFilesGroup:call(function(soundFilePath)
		return sound.load(soundFilePath, function()
			self.loadingResources[soundFilePath] = nil
			self.resourceCountLoaded = self.resourceCountLoaded + 1
			
			return self.observable:send({
				name = "notify",
				text = self.resourceCountLoaded .. "/" .. self.resourceCount
			})
		end)
	end)
end

CloudburstEngine.unloadResources = function(self)
	AudioManager:stop()
	
	self.soundFilesGroup:call(function(soundFilePath)
		return sound.unload(soundFilePath, function() end)
	end)
end

CloudburstEngine.checkResources = function(self)
	for filePath in pairs(self.loadingResources) do
		return
	end
	self.resourcesLoaded = true
	return self.timeManager:play()
end

CloudburstEngine.loadTimeManager = function(self)
	self.timeManager = TimeManager:new()
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
		local noteHandler = NoteHandler:new({
			inputType = inputType,
			inputIndex = inputIndex,
			engine = self
		})
		self.noteHandlers[noteHandler] = noteHandler
		noteHandler:load()
	end
end

CloudburstEngine.updateNoteHandlers = function(self)
	for noteHandler in pairs(self.noteHandlers) do
		noteHandler:update()
	end
end

CloudburstEngine.unloadNoteHandlers = function(self)
	for noteHandler in pairs(self.noteHandlers) do
		noteHandler:unload()
	end
	self.noteHandlers = nil
end

CloudburstEngine.loadNoteDrawers = function(self)
	self.noteDrawers = {}
	for layerIndex in self.noteChart:getLayerDataIndexIterator() do
		local layerData = self.noteChart:requireLayerData(layerIndex)
		if not layerData.invisible then
			for inputType, inputIndex in self.noteChart:getInputIteraator() do
				local noteDrawer = NoteDrawer:new({
					layerIndex = layerIndex,
					inputType = inputType,
					inputIndex = inputIndex,
					engine = self
				})
				self.noteDrawers[noteDrawer] = noteDrawer
				noteDrawer:load()
			end
		end
	end
end

CloudburstEngine.updateNoteDrawers = function(self)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:update()
	end
end

CloudburstEngine.unloadNoteDrawers = function(self)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:unload()
	end
	self.noteDrawers = nil
end

CloudburstEngine.reloadNoteDrawers = function(self)
	for noteDrawer in pairs(self.noteDrawers) do
		noteDrawer:reload()
	end
end

return CloudburstEngine
