local Class				= require("Class")
local Observable		= require("Observable")
local ScoreEngine		= require("sphere.models.RhythmModel.ScoreEngine")
local LogicEngine		= require("sphere.models.RhythmModel.LogicEngine")
local GraphicEngine		= require("sphere.models.RhythmModel.GraphicEngine")
local AudioEngine		= require("sphere.models.RhythmModel.AudioEngine")
local TimeEngine		= require("sphere.models.RhythmModel.TimeEngine")
local InputManager		= require("sphere.models.RhythmModel.InputManager")
local PauseManager		= require("sphere.models.RhythmModel.PauseManager")
local Test		= require("sphere.models.RhythmModel.LogicEngine.Test")

local RhythmModel = Class:new()

RhythmModel.construct = function(self)
	self.inputManager = InputManager:new()
	self.pauseManager = PauseManager:new()
	self.timeEngine = TimeEngine:new()
	self.scoreEngine = ScoreEngine:new()
	self.audioEngine = AudioEngine:new()
	self.logicEngine = LogicEngine:new()
	self.graphicEngine = GraphicEngine:new()
	self.observable = Observable:new()
	self.inputManager.rhythmModel = self
	self.pauseManager.rhythmModel = self
	self.timeEngine.rhythmModel = self
	self.scoreEngine.rhythmModel = self
	self.audioEngine.rhythmModel = self
	self.logicEngine.rhythmModel = self
	self.graphicEngine.rhythmModel = self
	self.observable.rhythmModel = self

	-- self.logicEngine.observable:add(self.audioEngine)

	self.inputManager.observable:add(self.logicEngine)
	self.inputManager.observable:add(self.observable)
end

RhythmModel.load = function(self)
	local replayModel = self.replayModel
	local scoreEngine = self.scoreEngine
	local logicEngine = self.logicEngine

	scoreEngine.timings = self.timings
	scoreEngine.judgements = self.judgements
	scoreEngine.hp = self.hp
	scoreEngine.settings = self.settings

	logicEngine.timings = self.timings
	replayModel.timings = self.timings

	self.inputManager.observable:add(replayModel)
	replayModel.observable:add(self.inputManager)

	self.prohibitSavingScore = false
end

RhythmModel.unload = function(self)
	local inputManager = self.inputManager
	local replayModel = self.replayModel

	inputManager.observable:remove(replayModel)
	replayModel.observable:remove(inputManager)
end

RhythmModel.loadAllEngines = function(self)
	local modifierModel = self.modifierModel
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

	self.pauseManager:load()
end

RhythmModel.loadLogicEngines = function(self)
	local modifierModel = self.modifierModel
	local timeEngine = self.timeEngine
	local scoreEngine = self.scoreEngine
	local logicEngine = self.logicEngine

	timeEngine:load()
	modifierModel:apply("TimeEngineModifier")
	timeEngine:updateTimeToPrepare()

	modifierModel:apply("LogicEngineModifier")

	scoreEngine:load()
	logicEngine:load()
end

RhythmModel.unloadAllEngines = function(self)
	self.audioEngine:unload()
	self.logicEngine:unload()
	self.graphicEngine:unload()

	for _, inputType, inputIndex in self.noteChart:getInputIterator() do
		self.observable:send({
			name = "keyreleased",
			virtual = true,
			inputType .. inputIndex
		})
	end
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
end

RhythmModel.update = function(self, dt)
	self.logicEngine:update()
	self.audioEngine:update()
	self.scoreEngine:update()
	self.graphicEngine:update(dt)
	self.modifierModel:update()
	self.pauseManager:update(dt)
end

RhythmModel.getResource = function(self, s)
	local aliases = self.resourceModel.aliases
	local resources = self.resourceModel.resources
	return resources[aliases[s]]
end

RhythmModel.setNoteChart = function(self, noteChart)
	assert(noteChart)
	self.noteChart = noteChart
	self.timeEngine.noteChart = noteChart
	self.scoreEngine.noteChart = noteChart
	self.logicEngine.noteChart = noteChart
	self.graphicEngine.noteChart = noteChart
end

RhythmModel.setDrawRange = function(self, range)
	self.graphicEngine.range = range
end

RhythmModel.setVolume = function(self, volume)
	self.audioEngine.volume = volume
	self.audioEngine:updateVolume()
end

RhythmModel.setAudioMode = function(self, mode)
	self.audioEngine.mode = mode
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

RhythmModel.setPauseTimes = function(self, ...)
	self.pauseManager:setPauseTimes(...)
end

RhythmModel.setVisualTimeRateScale = function(self, scaleSpeed)
	self.graphicEngine.scaleSpeed = scaleSpeed
end

return RhythmModel
