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
local Config = require("sphere.game.Config")

local CloudburstEngine = Class:new()

CloudburstEngine.autoplay = false
CloudburstEngine.paused = true
CloudburstEngine.rate = 1
CloudburstEngine.targetRate = 1
CloudburstEngine.allowStream = true

CloudburstEngine.load = function(self)
	self.observable = Observable:new()
	self.bgaContainer = AudioContainer:new()
	self.fgaContainer = AudioContainer:new()
	
	local volume = Config.data.volume
	self.bgaContainer:setVolume(volume.main * volume.music)
	self.fgaContainer:setVolume(volume.main * volume.effects)
	
	self.inputMode = self.noteChart.inputMode
	
	self.sharedLogicalNoteData = {}
	self.soundFiles = {}
	self.noteCount = 0
	
	self:loadNoteHandlers()
	self:loadNoteDrawers()
	self:loadTimeManager()
	
	NoteSkin.speed = Config.data.speed
	NoteSkin.targetSpeed = Config.data.speed
end

CloudburstEngine.update = function(self, dt)
	self.bgaContainer:update()
	self.fgaContainer:update()
	
	if self.rateTween then
		self.rateTween:update(dt)
		self:updateRate()
	end
	
	self:updateTimeManager(dt)
	self:updateNoteHandlers()
	self:updateNoteDrawers()
	
	self.noteSkin:update(dt)
end

CloudburstEngine.unload = function(self)
	self:unloadTimeManager()
	self:unloadNoteHandlers()
	self:unloadNoteDrawers()
	
	self.bgaContainer:stop()
	self.fgaContainer:stop()
end

CloudburstEngine.draw = function(self)
	self.noteSkin:draw()
end

CloudburstEngine.receive = function(self, event)
	local nearestNote
	if event.name == "keypressed" and self.score.promode then
		for noteHandler in pairs(self.noteHandlers) do
			local currentNote = noteHandler.currentNote
			if
				(not nearestNote or
				currentNote.startNoteData.timePoint.absoluteTime < nearestNote.startNoteData.timePoint.absoluteTime) and
				currentNote.state ~= "skipped" and
				currentNote:isReachable() and
				not currentNote.autoplay
			then
				nearestNote = noteHandler.currentNote
			end
		end
		if nearestNote then
			nearestNote.autoplay = true
		end
	end
	if not nearestNote then
		for noteHandler in pairs(self.noteHandlers) do
			noteHandler:receive(event)
		end
	end
	
	if event.name == "resize" then
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
		if key == "f2" then
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
			if self.targetRate - delta >= 0.1 then
				self.targetRate = self.targetRate - delta
				self:setRate(self.targetRate)
			end
			return self.observable:send({
				name = "notify",
				text = "rate: " .. self.targetRate
			})
		elseif key == "f6" then
			self.targetRate = self.targetRate + delta
			self:setRate(self.targetRate)
			return self.observable:send({
				name = "notify",
				text = "rate: " .. self.targetRate
			})
		end
	end
end

CloudburstEngine.playAudio = function(self, paths, layer, stream)
	if not paths then return end
	for i = 1, #paths do
		local audio
		if not stream then
			audio = AudioFactory:getSample(self.aliases[paths[i][1]])
		elseif self.allowStream then
			audio = AudioFactory:getStream(self.aliases[paths[i][1]])
		end
		if audio then
			audio.offset = self.timeManager.currentTime
			audio:play()
			audio:setRate(self.rate)
			audio:setBaseVolume(paths[i][2])
			if layer == "bga" then
				self.bgaContainer:add(audio)
			elseif layer == "fga" then
				self.fgaContainer:add(audio)
			end
		end
	end
end

CloudburstEngine.play = function(self)
	if self.paused then
		self.paused = false
		self.bgaContainer:play()
		self.fgaContainer:play()
		self.timeManager:play()
		self.bga:play()
	end
end

CloudburstEngine.pause = function(self)
	if not self.paused then
		self.paused = true
		self.bgaContainer:pause()
		self.fgaContainer:pause()
		self.timeManager:pause()
		self.bga:pause()
	end
end

CloudburstEngine.setRate = function(self, rate)
	self.rateTween = tween.new(0.25, self, {rate = rate}, "inOutQuad")
end

CloudburstEngine.updateRate = function(self)
	self.score.rate = self.rate
	self.noteSkin.rate = self.rate
	self.timeManager:setRate(self.rate)
	self.bga:setRate(self.rate)
	
	self.bgaContainer:setRate(self.rate)
	self.fgaContainer:setRate(self.rate)
	if self.pitch then
		self.bgaContainer:setPitch(self.rate)
		self.fgaContainer:setPitch(self.rate)
	end
end

CloudburstEngine.loadTimeManager = function(self)
	self.timeManager = TimeManager:new()
	self.timeManager.engine = self
	self.timeManager:load()
	self.currentTime = self.timeManager:getTime()
end

CloudburstEngine.updateTimeManager = function(self, dt)
	self.timeManager:update(dt)
	self.currentTime = self.timeManager:getTime()
	self.exactCurrentTime = self.timeManager:getExactTime()
end

CloudburstEngine.unloadTimeManager = function(self)
	self.timeManager:unload()
end

CloudburstEngine.getNoteHandler = function(self, inputType, inputIndex)
	if
		inputType == "key" or
		inputType == "scratch" or
		inputType == "measure" or
		inputType == "bt" or
		inputType == "fx" or
		inputType == "laserleft" or
		inputType == "laserright" or
		inputType == "auto"
	then
		return NoteHandler:new({
			inputType = inputType,
			inputIndex = inputIndex,
			engine = self
		})
	end
end

CloudburstEngine.loadNoteHandlers = function(self)
	self.noteHandlers = {}
	for inputType, inputIndex in self.noteChart:getInputIteraator() do
		local noteHandler = self:getNoteHandler(inputType, inputIndex)
		if noteHandler then
			self.noteHandlers[noteHandler] = noteHandler
			noteHandler:load()
		end
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

CloudburstEngine.getNoteDrawer = function(self, layerIndex, inputType, inputIndex)
	if
		inputType == "key" or
		inputType == "scratch" or
		inputType == "measure" or
		inputType == "bt" or
		inputType == "fx" or
		inputType == "laserleft" or
		inputType == "laserright" or
		inputType == "auto"
	then
		return NoteDrawer:new({
			layerIndex = layerIndex,
			inputType = inputType,
			inputIndex = inputIndex,
			engine = self
		})
	end
end

CloudburstEngine.loadNoteDrawers = function(self)
	self.noteDrawers = {}
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
