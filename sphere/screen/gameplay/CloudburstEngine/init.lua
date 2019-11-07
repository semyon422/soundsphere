local AudioFactory		= require("aqua.audio.AudioFactory")
local AudioContainer	= require("aqua.audio.Container")
local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local sound				= require("aqua.sound")
local NoteDrawer		= require("sphere.screen.gameplay.CloudburstEngine.NoteDrawer")
local NoteHandler		= require("sphere.screen.gameplay.CloudburstEngine.NoteHandler")
local NoteSkin			= require("sphere.screen.gameplay.CloudburstEngine.NoteSkin")
local TimeManager		= require("sphere.screen.gameplay.CloudburstEngine.TimeManager")
local Config			= require("sphere.config.Config")
local tween				= require("tween")

local CloudburstEngine = Class:new()

CloudburstEngine.autoplay = false
CloudburstEngine.paused = true
CloudburstEngine.timeRate = 1
CloudburstEngine.targetTimeRate = 1

CloudburstEngine.load = function(self)
	self.observable = Observable:new()
	self.bgaContainer = AudioContainer:new()
	self.fgaContainer = AudioContainer:new()
	
	self.bgaContainer:setVolume(Config:get("volume.global") * Config:get("volume.music"))
	self.fgaContainer:setVolume(Config:get("volume.global") * Config:get("volume.effects"))
	
	self.inputMode = self.noteChart.inputMode
	self.inputStats = {}
	
	self.sharedLogicalNoteData = {}
	self.soundFiles = {}
	self.noteCount = 0
	
	self:loadNoteHandlers()
	self:loadNoteDrawers()
	self:loadTimeManager()
	
	NoteSkin.visualTimeRate = Config.data.speed
	NoteSkin.targetVisualTimeRate = Config.data.speed
end

CloudburstEngine.update = function(self, dt)
	self.bgaContainer:update()
	self.fgaContainer:update()
	
	if self.timeRateTween then
		self.timeRateTween:update(dt)
		self:updateTimeRate()
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
	if event.name == "keypressed" and self.score.promode and not event.virtual then
		for noteHandler in pairs(self.noteHandlers) do
			local currentNote = noteHandler.currentNote
			if
				currentNote and
				(
					not nearestNote or
					currentNote.startNoteData.timePoint.absoluteTime < nearestNote.startNoteData.timePoint.absoluteTime
				) and
				currentNote.state ~= "skipped" and
				currentNote:isReachable() and
				not currentNote.startNoteData.autoplay and
				not currentNote.autoplay
			then
				nearestNote = currentNote
			end
		end
		if nearestNote then
			local key = event.args[1]
			local virtualKey = nearestNote.startNoteData.inputType .. nearestNote.startNoteData.inputIndex
			
			self.inputStats[virtualKey] = self.inputStats[virtualKey] or {}
			local inputCount = self.inputStats[virtualKey]
			inputCount[key] = (inputCount[key] or 0) + 1
			
			nearestNote.autoplay = true
			self.lastNearestNote = nearestNote
		end
	end
	nearestNote = self.lastNearestNote
	if nearestNote and not nearestNote:isReachable() then
		nearestNote = nil
	end
	if not nearestNote and event.virtual or event.name == "keyreleased" then
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
			NoteSkin.targetVisualTimeRate = -NoteSkin.targetVisualTimeRate
			NoteSkin:setVisualTimeRate(NoteSkin.targetVisualTimeRate)
			return self.observable:send({
				name = "notify",
				text = "visualTimeRate: " .. NoteSkin.targetVisualTimeRate
			})
		elseif key == "f3" then
			if math.abs(NoteSkin.targetVisualTimeRate - delta) > 0.001 then
				NoteSkin.targetVisualTimeRate = NoteSkin.targetVisualTimeRate - delta
				NoteSkin:setVisualTimeRate(NoteSkin.targetVisualTimeRate)
			else
				NoteSkin.targetVisualTimeRate = 0
				NoteSkin:setVisualTimeRate(NoteSkin.targetVisualTimeRate)
			end
			return self.observable:send({
				name = "notify",
				text = "visualTimeRate: " .. NoteSkin.targetVisualTimeRate
			})
		elseif key == "f4" then
			if math.abs(NoteSkin.targetVisualTimeRate + delta) > 0.001 then
				NoteSkin.targetVisualTimeRate = NoteSkin.targetVisualTimeRate + delta
				NoteSkin:setVisualTimeRate(NoteSkin.targetVisualTimeRate)
			else
				NoteSkin.targetVisualTimeRate = 0
				NoteSkin:setVisualTimeRate(NoteSkin.targetVisualTimeRate)
			end
			return self.observable:send({
				name = "notify",
				text = "visualTimeRate: " .. NoteSkin.targetVisualTimeRate
			})
		elseif key == "f5" then
			if self.targetTimeRate - delta >= 0.1 then
				self.targetTimeRate = self.targetTimeRate - delta
				self:setTimeRate(self.targetTimeRate)
			end
			return self.observable:send({
				name = "notify",
				text = "timeRate: " .. self.targetTimeRate
			})
		elseif key == "f6" then
			self.targetTimeRate = self.targetTimeRate + delta
			self:setTimeRate(self.targetTimeRate)
			return self.observable:send({
				name = "notify",
				text = "timeRate: " .. self.targetTimeRate
			})
		end
	end
end

CloudburstEngine.playAudio = function(self, paths, layer, keysound, stream)
	if not paths then return end
	for i = 1, #paths do
		local path = paths[i][1]
		local audio
		local aliases = self.localAliases
		if not keysound and not aliases[path] then
			aliases = self.globalAliases
		end
		if not stream or not Config:get("audio.stream") then
			audio = AudioFactory:getSample(aliases[paths[i][1]])
		else
			audio = AudioFactory:getStream(aliases[paths[i][1]])
		end
		if audio then
			audio.offset = self.timeManager.currentTime
			audio:play()
			audio:setRate(self.timeRate)
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

CloudburstEngine.setTimeRate = function(self, timeRate)
	self.timeRateTween = tween.new(0.25, self, {timeRate = timeRate}, "inOutQuad")
end

CloudburstEngine.updateTimeRate = function(self)
	self.score.timeRate = self.timeRate
	self.noteSkin.timeRate = self.timeRate
	self.timeManager:setRate(self.timeRate)
	self.bga:setTimeRate(self.timeRate)
	
	self.bgaContainer:setRate(self.timeRate)
	self.fgaContainer:setRate(self.timeRate)
	if self.pitch then
		self.bgaContainer:setPitch(self.timeRate)
		self.fgaContainer:setPitch(self.timeRate)
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
