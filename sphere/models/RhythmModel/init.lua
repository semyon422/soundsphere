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

	timeEngine.observable:add(audioEngine)
	timeEngine.observable:add(scoreEngine)
	timeEngine.observable:add(logicEngine)
	timeEngine.observable:add(graphicEngine)
	timeEngine.observable:add(replayModel)
	timeEngine.observable:add(inputManager)
	timeEngine.logicEngine = logicEngine
	timeEngine.audioEngine = audioEngine

	logicEngine.observable:add(modifierModel)
	logicEngine.observable:add(audioEngine)
	logicEngine.scoreEngine = scoreEngine

	scoreEngine.timeEngine = timeEngine
	audioEngine.timeEngine = timeEngine
	pauseManager.timeEngine = timeEngine

	graphicEngine.logicEngine = logicEngine

	inputManager.observable:add(logicEngine)
	inputManager.observable:add(replayModel)

	replayModel.observable:add(inputManager)
	replayModel.timeEngine = timeEngine
	replayModel.logicEngine = logicEngine

	timeEngine.observable:add(observable)
	scoreEngine.observable:add(observable)
	logicEngine.observable:add(observable)
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

	timeEngine.observable:remove(audioEngine)
	timeEngine.observable:remove(scoreEngine)
	timeEngine.observable:remove(logicEngine)
	timeEngine.observable:remove(graphicEngine)
	timeEngine.observable:remove(replayModel)
	timeEngine.observable:remove(inputManager)

	logicEngine.observable:remove(modifierModel)
	logicEngine.observable:remove(audioEngine)

	inputManager.observable:remove(logicEngine)
	inputManager.observable:remove(replayModel)

	replayModel.observable:remove(inputManager)

	timeEngine.observable:remove(observable)
	scoreEngine.observable:remove(observable)
	logicEngine.observable:remove(observable)
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
	modifierModel:apply("ScoreEngineModifier")

	audioEngine:load()
	modifierModel:apply("AudioEngineModifier")

	modifierModel:apply("LogicEngineModifier")
	modifierModel:apply("GraphicEngineModifier")

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

	modifierModel:apply("NoteChartModifier")

	timeEngine:load()
	modifierModel:apply("TimeEngineModifier")

	scoreEngine:load()
	modifierModel:apply("ScoreEngineModifier")

	modifierModel:apply("LogicEngineModifier")

	logicEngine:load()
	replayModel:load()
end

RhythmModel.unloadAllEngines = function(self)
	self.timeEngine:unload()
	self.scoreEngine:unload()
	self.audioEngine:unload()
	self.logicEngine:unload()
	self.graphicEngine:unload()
end

RhythmModel.unloadLogicEngines = function(self)
	self.timeEngine:unload()
	self.scoreEngine:unload()
	self.logicEngine:unload()
end

RhythmModel.receive = function(self, event)
	self.timeEngine:receive(event)
	self.modifierModel:receive(event)
	if self.timeEngine.timeRate ~= 0 then
		self.inputManager:receive(event)
	end
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

RhythmModel.setResourceAliases = function(self, localAliases, globalAliases)
	self.audioEngine.localAliases = localAliases
	self.audioEngine.globalAliases = globalAliases
	self.graphicEngine.localAliases = localAliases
	self.graphicEngine.globalAliases = globalAliases
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

RhythmModel.setTimeRound = function(self, needRound)
	self.inputManager.needRound = needRound
end

RhythmModel.setTimeToPrepare = function(self, timeToPrepare)
	self.timeEngine.timeToPrepare = timeToPrepare
end

RhythmModel.setInputOffset = function(self, offset)
	self.inputManager:setInputOffset(offset)
end

RhythmModel.setVisualOffset = function(self, offset)
	self.graphicEngine:setVisualOffset(offset)
end

RhythmModel.setScoreBasePath = function(self, path)
	self.scoreEngine:setBasePath(path)
end

return RhythmModel
