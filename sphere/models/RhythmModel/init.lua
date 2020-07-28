local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local ScoreEngine		= require("sphere.models.RhythmModel.ScoreEngine")
local LogicEngine		= require("sphere.models.RhythmModel.LogicEngine")
local GraphicEngine		= require("sphere.models.RhythmModel.GraphicEngine")
local AudioEngine		= require("sphere.models.RhythmModel.AudioEngine")
local TimeEngine		= require("sphere.models.RhythmModel.TimeEngine")
local InputManager		= require("sphere.models.RhythmModel.InputManager")
local ReplayManager		= require("sphere.models.RhythmModel.ReplayManager")
local ModifierModel		= require("sphere.models.ModifierModel")

local RhythmModel = Class:new()

RhythmModel.construct = function(self)
	local modifierModel = ModifierModel:new()
	local inputManager = InputManager:new()
	local replayManager = ReplayManager:new()
	local timeEngine = TimeEngine:new()
	local scoreEngine = ScoreEngine:new()
	local audioEngine = AudioEngine:new()
	local logicEngine = LogicEngine:new()
	local graphicEngine = GraphicEngine:new()

	self.modifierModel = modifierModel
	self.inputManager = inputManager
	self.replayManager = replayManager
	self.timeEngine = timeEngine
	self.scoreEngine = scoreEngine
	self.audioEngine = audioEngine
	self.logicEngine = logicEngine
	self.graphicEngine = graphicEngine

	timeEngine.observable:add(audioEngine)
	timeEngine.observable:add(scoreEngine)
	timeEngine.observable:add(logicEngine)
	timeEngine.observable:add(graphicEngine)
	timeEngine.observable:add(replayManager)
	timeEngine.observable:add(inputManager)
	timeEngine.logicEngine = logicEngine
	timeEngine.audioEngine = audioEngine

	logicEngine.observable:add(modifierModel)
	logicEngine.observable:add(audioEngine)
	logicEngine.scoreEngine = scoreEngine

	modifierModel.timeEngine = timeEngine
	modifierModel.scoreEngine = scoreEngine
	modifierModel.audioEngine = audioEngine
	modifierModel.graphicEngine = graphicEngine
	modifierModel.logicEngine = logicEngine

	scoreEngine.timeEngine = timeEngine

	audioEngine.timeEngine = timeEngine

	graphicEngine.logicEngine = logicEngine

	inputManager.observable:add(logicEngine)
	inputManager.observable:add(replayManager)

	replayManager.observable:add(inputManager)
	replayManager.timeEngine = timeEngine
	replayManager.logicEngine = logicEngine

	local observable = Observable:new()
	self.observable = observable

	timeEngine.observable:add(observable)
	scoreEngine.observable:add(observable)
	logicEngine.observable:add(observable)
	inputManager.observable:add(observable)
	graphicEngine.observable:add(observable)
end

RhythmModel.load = function(self)
end

RhythmModel.unload = function(self)
	self.timeEngine:unload()
	self.logicEngine:unload()
	self.scoreEngine:unload()
	self.graphicEngine:unload()
	self.audioEngine:unload()
end

RhythmModel.receive = function(self, event)
	self.timeEngine:update(0)
	self.modifierModel:receive(event)
	self.inputManager:receive(event)
end

RhythmModel.update = function(self, dt)
	self.replayManager:update()
	self.logicEngine:update()
	self.timeEngine:update(dt)
	self.audioEngine:update()
	self.scoreEngine:update()
	self.graphicEngine:update(dt)
	self.modifierModel:update()
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

return RhythmModel
