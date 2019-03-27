local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local AudioContainer = require("aqua.audio.Container")
local AudioFactory = require("aqua.audio.AudioFactory")
local sound = require("aqua.sound")
local tween = require("tween")
local NoteHandler = require("sphere.game.CloudburstEngine.NoteHandler")
local NoteDrawer = require("sphere.game.CloudburstEngine.NoteDrawer")
local NoteSkin = require("sphere.game.CloudburstEngine.NoteSkin")
local TimeManager = require("sphere.game.CloudburstEngine.TimeManager")

local CloudburstEngine = Class:new()

CloudburstEngine.autoplay = false
CloudburstEngine.paused = true
CloudburstEngine.rate = 1
CloudburstEngine.targetRate = 1

CloudburstEngine.load = function(self)
	self.observable = Observable:new()
	self.audioContainer = AudioContainer:new()
	
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
	
	self.audioContainer:update()
	
	self:updateTimeManager()
	self:updateNoteHandlers()
	self:updateNoteDrawers()
	
	self.noteSkin:update(dt)
end

CloudburstEngine.unload = function(self)
	self:unloadTimeManager()
	self:unloadNoteHandlers()
	self:unloadNoteDrawers()
end

CloudburstEngine.draw = function(self)
	self.noteSkin:draw()
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
		local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
		local control = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
		local delta
		if shift and control then
			delta = 5
		elseif shift then
			delta = 0.05
		elseif control then
			delta = 1
		else
			delta = 0.1
		end
		if key == "escape" and not shift then
			if self.paused then
				self:play()
			else
				self:pause()
			end
		elseif key == "f2" then
			NoteSkin.targetSpeed = -NoteSkin.targetSpeed
			NoteSkin:setSpeed(NoteSkin.targetSpeed)
			return self.observable:send({
				name = "notify",
				text = "speed: " .. NoteSkin.targetSpeed
			})
		elseif key == "f3" then
			if math.abs(NoteSkin.targetSpeed - delta) > 0.001 then
				NoteSkin.targetSpeed = NoteSkin.targetSpeed - delta
				NoteSkin:setSpeed(NoteSkin.targetSpeed)
			else
				NoteSkin.targetSpeed = 0
				NoteSkin:setSpeed(NoteSkin.targetSpeed)
			end
			return self.observable:send({
				name = "notify",
				text = "speed: " .. NoteSkin.targetSpeed
			})
		elseif key == "f4" then
			if math.abs(NoteSkin.targetSpeed + delta) > 0.001 then
				NoteSkin.targetSpeed = NoteSkin.targetSpeed + delta
				NoteSkin:setSpeed(NoteSkin.targetSpeed)
			else
				NoteSkin.targetSpeed = 0
				NoteSkin:setSpeed(NoteSkin.targetSpeed)
			end
			return self.observable:send({
				name = "notify",
				text = "speed: " .. NoteSkin.targetSpeed
			})
		elseif key == "f5" then
			if math.abs(self.targetRate - delta) > 0.001 then
				self.targetRate = self.targetRate - delta
				self:setRate(self.targetRate)
			end
			return self.observable:send({
				name = "notify",
				text = "rate: " .. self.targetRate
			})
		elseif key == "f6" then
			if math.abs(self.targetRate + delta) > 0.001 then
				self.targetRate = self.targetRate + delta
				self:setRate(self.targetRate)
			end
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
		local audio = AudioFactory:getAudio(self.aliases[paths[i][1]])
		if audio then
			audio:play()
			audio:setRate(self.rate)
			audio:setVolume(paths[i][2])
			self.audioContainer:add(audio)
		end
	end
end

CloudburstEngine.play = function(self)
	if self.paused then
		self.paused = false
		self.audioContainer:play()
		return self.timeManager:play()
	end
end

CloudburstEngine.pause = function(self)
	if not self.paused then
		self.paused = true
		self.audioContainer:pause()
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
	self.audioContainer:setRate(self.rate)
end

CloudburstEngine.loadTimeManager = function(self)
	self.timeManager = TimeManager:new()
	self.timeManager.engine = self
	self.timeManager:load()
	self.currentTime = self.timeManager:getTime()
end

CloudburstEngine.updateTimeManager = function(self)
	self.timeManager:update()
	self.currentTime = self.timeManager:getTime()
	self.roundedTime = self.timeManager:getRoundedTime()
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
