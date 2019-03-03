local Container = require("aqua.graphics.Container")
local Class = require("aqua.util.Class")
local Group = require("aqua.util.Group")
local Observable = require("aqua.util.Observable")
local AudioManager = require("aqua.audio.AudioManager")
local sound = require("aqua.sound")

local tween = require("tween")

local CloudburstEngine = Class:new()

local NoteHandler = require("sphere.game.CloudburstEngine.NoteHandler")
local NoteDrawer = require("sphere.game.CloudburstEngine.NoteDrawer")

local NoteSkin = require("sphere.game.CloudburstEngine.NoteSkin")
local Score = require("sphere.game.CloudburstEngine.Score")
local TimeManager = require("sphere.game.CloudburstEngine.TimeManager")

CloudburstEngine.autoplay = false
CloudburstEngine.paused = true
CloudburstEngine.rate = 1
CloudburstEngine.targetRate = 1

CloudburstEngine.load = function(self)
	self.observable = Observable:new()
	
	self.inputMode = self.noteChart.inputMode
	
	self.sharedLogicalNoteData = {}
	self.soundFiles = {}
	
	self:loadNoteHandlers()
	self:loadNoteDrawers()
	self:loadTimeManager()
	
	self.noteSkin.allcs:reload()
	self.noteSkin.cs:reload()
end

CloudburstEngine.update = function(self, dt)
	if self.rateTween then
		self.rateTween:update(dt)
		self:updateRate()
	end
	
	self.noteSkin:update(dt)
	
	self:updateTimeManager()
	self:updateNoteHandlers()
	self:updateNoteDrawers()
end

CloudburstEngine.unload = function(self)
	self:unloadTimeManager()
	self:unloadNoteHandlers()
	self:unloadNoteDrawers()
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
			self:play()
		elseif key == "f1" then
			self:pause()
		elseif key == "f3" then
			if NoteSkin.targetSpeed - 0.1 >= 0.1 then
				NoteSkin.targetSpeed = NoteSkin.targetSpeed - 0.1
				NoteSkin:setSpeed(NoteSkin.targetSpeed)
				return self.observable:send({
					name = "notify",
					text = "speed: " .. NoteSkin.targetSpeed
				})
			end
		elseif key == "f4" then
			NoteSkin.targetSpeed = NoteSkin.targetSpeed + 0.1
			NoteSkin:setSpeed(NoteSkin.targetSpeed)
			return self.observable:send({
				name = "notify",
				text = "speed: " .. NoteSkin.targetSpeed
			})
		elseif key == "f5" then
			if self.targetRate - 0.1 >= 0.1 then
				self.targetRate = self.targetRate - 0.1
				self:setRate(self.targetRate)
				return self.observable:send({
					name = "notify",
					text = "rate: " .. self.targetRate
				})
			end
		elseif key == "f6" then
			self.targetRate = self.targetRate + 0.1
			self:setRate(self.targetRate)
			return self.observable:send({
				name = "notify",
				text = "rate: " .. self.targetRate
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

CloudburstEngine.playAudio = function(self, paths)
	if not paths then return end
	for i = 1, #paths do
		local audio = AudioManager:getAudio(self.aliases[paths[i]])
		if audio then
			audio:play()
			audio:rate(self.rate)
		end
	end
end

CloudburstEngine.play = function(self)
	if self.paused then
		self.paused = false
		AudioManager:play()
		return self.timeManager:play()
	end
end

CloudburstEngine.pause = function(self)
	if not self.paused then
		self.paused = true
		AudioManager:pause()
		return self.timeManager:pause()
	end
end

CloudburstEngine.setRate = function(self, rate)
	self.rateTween = tween.new(0.25, self, {rate = rate}, "inOutQuad")
end

CloudburstEngine.updateRate = function(self)
	self.score.rate = self.rate
	self.noteSkin.rate = self.rate
	self.timeManager:setRate(self.rate)
	AudioManager:rate(self.rate)
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
