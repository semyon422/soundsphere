local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local ScoreEngine		= require("sphere.models.RhythmModel.ScoreEngine")
local LogicEngine		= require("sphere.models.RhythmModel.LogicEngine")
local GraphicEngine		= require("sphere.models.RhythmModel.GraphicEngine")
local AudioEngine		= require("sphere.models.RhythmModel.AudioEngine")
local TimeEngine		= require("sphere.models.RhythmModel.TimeEngine")
local InputManager		= require("sphere.models.RhythmModel.InputManager")
local PauseManager		= require("sphere.models.RhythmModel.PauseManager")
local ReplayModel		= require("sphere.models.ReplayModel")
local ModifierModel		= require("sphere.models.ModifierModel")
local Test		= require("sphere.models.RhythmModel.LogicEngine.Test")

local RhythmModel = Class:new()

RhythmModel.construct = function(self)
	self.modifierModel = ModifierModel:new()
	self.inputManager = InputManager:new()
	self.pauseManager = PauseManager:new()
	self.replayModel = ReplayModel:new()
	self.timeEngine = TimeEngine:new()
	self.scoreEngine = ScoreEngine:new()
	self.audioEngine = AudioEngine:new()
	self.logicEngine = LogicEngine:new()
	self.graphicEngine = GraphicEngine:new()
	self.observable = Observable:new()
	self.modifierModel.rhythmModel = self
	self.inputManager.rhythmModel = self
	self.pauseManager.rhythmModel = self
	self.replayModel.rhythmModel = self
	self.timeEngine.rhythmModel = self
	self.scoreEngine.rhythmModel = self
	self.audioEngine.rhythmModel = self
	self.logicEngine.rhythmModel = self
	self.graphicEngine.rhythmModel = self
	self.observable.rhythmModel = self
end

RhythmModel.load = function(self)
	local modifierModel = self.modifierModel
	local inputManager = self.inputManager
	local pauseManager = self.pauseManager
	local replayModel = self.replayModel
	local timeEngine = self.timeEngine
	local scoreEngine = self.scoreEngine
	local audioEngine = self.audioEngine
	local logicEngine = self.logicEngine
	local graphicEngine = self.graphicEngine
	local observable = self.observable

	logicEngine.observable:add(modifierModel)
	logicEngine.observable:add(audioEngine)

	scoreEngine.configModel = self.configModel
	scoreEngine.timings = self.timings
	scoreEngine.judgements = self.judgements
	scoreEngine.hp = self.hp
	scoreEngine.settings = self.settings

	logicEngine.timings = self.timings

	inputManager.observable:add(logicEngine)
	inputManager.observable:add(replayModel)

	replayModel.observable:add(inputManager)
	replayModel.timings = self.timings

	inputManager.observable:add(observable)
	graphicEngine.observable:add(observable)
end

RhythmModel.unload = function(self)
	local modifierModel = self.modifierModel
	local inputManager = self.inputManager
	local replayModel = self.replayModel
	local timeEngine = self.timeEngine
	local scoreEngine = self.scoreEngine
	local audioEngine = self.audioEngine
	local logicEngine = self.logicEngine
	local graphicEngine = self.graphicEngine
	local observable = self.observable

	logicEngine.observable:remove(modifierModel)
	logicEngine.observable:remove(audioEngine)

	inputManager.observable:remove(logicEngine)
	inputManager.observable:remove(replayModel)

	replayModel.observable:remove(inputManager)

	inputManager.observable:remove(observable)
	graphicEngine.observable:remove(observable)
end

RhythmModel.loadAllEngines = function(self)
	local modifierModel = self.modifierModel
	local replayModel = self.replayModel
	local timeEngine = self.timeEngine
	local scoreEngine = self.scoreEngine
	local audioEngine = self.audioEngine
	local logicEngine = self.logicEngine
	local graphicEngine = self.graphicEngine

	timeEngine:load()
	modifierModel:apply("TimeEngineModifier")
	timeEngine:updateTimeToPrepare()

	scoreEngine:load()
	audioEngine:load()

	modifierModel:apply("LogicEngineModifier")

	logicEngine:load()
	graphicEngine:load()
	replayModel:load()

	self.pauseManager:load()
end

RhythmModel.loadLogicEngines = function(self)
	local modifierModel = self.modifierModel
	local replayModel = self.replayModel
	local timeEngine = self.timeEngine
	local scoreEngine = self.scoreEngine
	local logicEngine = self.logicEngine

	timeEngine:load()
	modifierModel:apply("TimeEngineModifier")
	timeEngine:updateTimeToPrepare()

	modifierModel:apply("LogicEngineModifier")

	scoreEngine:load()
	logicEngine:load()
	replayModel:load()
end

RhythmModel.unloadAllEngines = function(self)
	self.audioEngine:unload()
	self.logicEngine:unload()
	self.graphicEngine:unload()
end

RhythmModel.unloadLogicEngines = function(self)
	self.scoreEngine:unload()
	self.logicEngine:unload()
end

RhythmModel.receive = function(self, event)
	if event.name == "framestarted" then
		self.timeEngine:sync(event)
		self.replayModel.currentTime = self.timeEngine.currentTime
		return
	end

	self.modifierModel:receive(event)
	self.inputManager:receive(event)
	self.pauseManager:receive(event)
end

RhythmModel.update = function(self, dt)
	self.replayModel:update()
	self.logicEngine:update()
	self.audioEngine:update()
	self.scoreEngine:update()
	self.graphicEngine:update(dt)
	self.modifierModel:update()
	self.pauseManager:update(dt)
end

RhythmModel.setNoteChart = function(self, noteChart)
	assert(noteChart)
	self.modifierModel.noteChart = noteChart
	self.timeEngine.noteChart = noteChart
	self.scoreEngine.noteChart = noteChart
	self.logicEngine.noteChart = noteChart
	self.graphicEngine.noteChart = noteChart
end

RhythmModel.setNoteSkin = function(self, noteSkin)
	self.graphicEngine.noteSkin = noteSkin
end

RhythmModel.setInputBindings = function(self, inputBindings)
	assert(inputBindings)
	self.inputManager:setBindings(inputBindings)
end

RhythmModel.setResourceAliases = function(self, aliases)
	self.audioEngine.aliases = aliases
	self.graphicEngine.aliases = aliases
end

RhythmModel.setVolume = function(self, layer, value)
	if layer == "global" then
		self.audioEngine.globalVolume = value
	elseif layer == "music" then
		self.audioEngine.musicVolume = value
	elseif layer == "effects" then
		self.audioEngine.effectsVolume = value
	end
	self.audioEngine:updateVolume()
end

RhythmModel.setAudioMode = function(self, layer, value)
	if layer == "primary" then
		self.audioEngine.primaryAudioMode = value
	elseif layer == "secondary" then
		self.audioEngine.secondaryAudioMode = value
	end
end

RhythmModel.setVisualTimeRate = function(self, visualTimeRate)
	self.graphicEngine.visualTimeRate = visualTimeRate
	self.graphicEngine.targetVisualTimeRate = visualTimeRate
end

RhythmModel.setLongNoteShortening = function(self, longNoteShortening)
	self.graphicEngine.longNoteShortening = longNoteShortening
end

RhythmModel.setTimeToPrepare = function(self, timeToPrepare)
	self.timeEngine.timeToPrepare = timeToPrepare
end

RhythmModel.setInputOffset = function(self, offset)
	self.timeEngine.inputOffset = math.floor(offset * 1024) / 1024
end

RhythmModel.setVisualOffset = function(self, offset)
	self.timeEngine.visualOffset = offset
end

RhythmModel.setScoreBasePath = function(self, path)
	self.scoreEngine:setBasePath(path)
end

RhythmModel.setPauseTimes = function(self, ...)
	self.pauseManager:setPauseTimes(...)
end

RhythmModel.setVisualTimeRateScale = function(self, scaleSpeed)
	self.graphicEngine.scaleSpeed = scaleSpeed
end

RhythmModel.setScaleInputOffset = function(self, scaleInputOffset)
	-- self.inputManager:setScaleInputOffset(scaleInputOffset)
end

RhythmModel.setScaleVisualOffset = function(self, scaleVisualOffset)
	-- self.graphicEngine:setScaleVisualOffset(scaleVisualOffset)
end

return RhythmModel
