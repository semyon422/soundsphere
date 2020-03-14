local AudioFactory		= require("aqua.audio.AudioFactory")
local AudioContainer	= require("aqua.audio.Container")
local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local sound				= require("aqua.sound")
local NoteHandler		= require("sphere.screen.gameplay.LogicEngine.NoteHandler")
local TimeManager		= require("sphere.screen.gameplay.LogicEngine.TimeManager")
local Config			= require("sphere.config.Config")
local tween				= require("tween")

local LogicEngine = Class:new()

LogicEngine.autoplay = false
LogicEngine.paused = true
LogicEngine.timeRate = 1
LogicEngine.targetTimeRate = 1

LogicEngine.load = function(self)
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
	self:loadTimeManager()
end

LogicEngine.update = function(self, dt)
	self.bgaContainer:update()
	self.fgaContainer:update()
	
	if self.timeRateTween then
		self.timeRateTween:update(dt)
		self:updateTimeRate()
	end
	
	self:updateTimeManager(dt)
	self:updateNoteHandlers()
end

LogicEngine.unload = function(self)
	self:unloadTimeManager()
	self:unloadNoteHandlers()
	
	self.bgaContainer:stop()
	self.fgaContainer:stop()
end

LogicEngine.receive = function(self, event)
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
	
	if event.name == "keypressed" then
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
		
		if key == "f5" then
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

LogicEngine.playAudio = function(self, paths, layer, keysound, stream)
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
			audio:setRate(self.timeRate)
			audio:setBaseVolume(paths[i][2])
			if layer == "bga" then
				self.bgaContainer:add(audio)
			elseif layer == "fga" then
				self.fgaContainer:add(audio)
			end
			audio:play()
		end
	end
end

LogicEngine.play = function(self)
	if self.paused then
		self.paused = false
		self.bgaContainer:play()
		self.fgaContainer:play()
		self.timeManager:play()
	end
end

LogicEngine.pause = function(self)
	if not self.paused then
		self.paused = true
		self.bgaContainer:pause()
		self.fgaContainer:pause()
		self.timeManager:pause()
	end
end

LogicEngine.setTimeRate = function(self, timeRate)
	self.timeRateTween = tween.new(0.25, self, {timeRate = timeRate}, "inOutQuad")
end

LogicEngine.updateTimeRate = function(self)
	self.score.timeRate = self.timeRate
	self.timeManager:setRate(self.timeRate)
	
	self.bgaContainer:setRate(self.timeRate)
	self.fgaContainer:setRate(self.timeRate)
	if self.pitch then
		self.bgaContainer:setPitch(self.timeRate)
		self.fgaContainer:setPitch(self.timeRate)
	end
end

LogicEngine.loadTimeManager = function(self)
	self.timeManager = TimeManager:new()
	self.timeManager.logicEngine = self
	self.timeManager:load()
	self.currentTime = self.timeManager:getTime()
end

LogicEngine.updateTimeManager = function(self, dt)
	self.timeManager:update(dt)
	self.currentTime = self.timeManager:getTime()
	self.exactCurrentTime = self.timeManager:getExactTime()
end

LogicEngine.unloadTimeManager = function(self)
	self.timeManager:unload()
end

LogicEngine.getNoteHandler = function(self, inputType, inputIndex)
	return NoteHandler:new({
		inputType = inputType,
		inputIndex = inputIndex,
		logicEngine = self
	})
end

LogicEngine.loadNoteHandlers = function(self)
	self.noteHandlers = {}
	for inputType, inputIndex in self.noteChart:getInputIteraator() do
		local noteHandler = self:getNoteHandler(inputType, inputIndex)
		if noteHandler then
			self.noteHandlers[noteHandler] = noteHandler
			noteHandler:load()
		end
	end
end

LogicEngine.updateNoteHandlers = function(self)
	for noteHandler in pairs(self.noteHandlers) do
		noteHandler:update()
	end
end

LogicEngine.unloadNoteHandlers = function(self)
	for noteHandler in pairs(self.noteHandlers) do
		noteHandler:unload()
	end
	self.noteHandlers = nil
end

return LogicEngine
