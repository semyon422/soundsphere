local Class				= require("aqua.util.Class")
local ScoreEngine		= require("sphere.models.RhythmModel.ScoreEngine")
local LogicEngine		= require("sphere.models.RhythmModel.LogicEngine")
local GraphicEngine		= require("sphere.models.RhythmModel.GraphicEngine")
local AudioEngine		= require("sphere.models.RhythmModel.AudioEngine")
local TimeEngine		= require("sphere.models.RhythmModel.TimeEngine")
local InputManager		= require("sphere.models.RhythmModel.InputManager")
local ReplayManager		= require("sphere.models.RhythmModel.ReplayManager")
local ModifierSequence	= require("sphere.models.RhythmModel.ModifierManager.ModifierSequence")

local RhythmModel = Class:new()

RhythmModel.construct = function(self)
	local inputManager = InputManager:new()
	local replayManager = ReplayManager:new()
	local modifierSequence = ModifierSequence:new()
	local timeEngine = TimeEngine:new()
	local scoreEngine = ScoreEngine:new()
	local audioEngine = AudioEngine:new()
	local logicEngine = LogicEngine:new()
	local graphicEngine = GraphicEngine:new()

	self.inputManager = inputManager
	self.replayManager = replayManager
	self.modifierSequence = modifierSequence
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

	logicEngine.observable:add(modifierSequence)
	logicEngine.observable:add(audioEngine)
	logicEngine.scoreEngine = scoreEngine

	modifierSequence.timeEngine = timeEngine
	modifierSequence.scoreEngine = scoreEngine
	modifierSequence.audioEngine = audioEngine
	modifierSequence.graphicEngine = graphicEngine
	modifierSequence.logicEngine = logicEngine

	scoreEngine.timeEngine = timeEngine

	audioEngine.timeEngine = timeEngine

	graphicEngine.logicEngine = logicEngine

	inputManager.observable:add(logicEngine)
	inputManager.observable:add(replayManager)

	replayManager.observable:add(inputManager)
	replayManager.timeEngine = timeEngine
	replayManager.logicEngine = logicEngine
end

RhythmModel.load = function(self)
	local modifierSequence = self.modifierSequence

	modifierSequence:apply("NoteChartModifier")

	self.timeEngine:load()
	modifierSequence:apply("TimeEngineModifier")

	self.scoreEngine:load()
	modifierSequence:apply("ScoreEngineModifier")

	self.audioEngine:load()
	modifierSequence:apply("AudioEngineModifier")

	modifierSequence:apply("LogicEngineModifier")
	modifierSequence:apply("GraphicEngineModifier")

	self.logicEngine:load()
	self.graphicEngine:load()
	self.replayManager:load()
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
	-- self.timeEngine:receive(event)

	-- self.audioEngine:receive(event)
	self.modifierSequence:receive(event)
	self.inputManager:receive(event)
	-- self.scoreEngine:receive(event)
	-- self.graphicEngine:receive(event)
end

RhythmModel.update = function(self, dt)
	self.replayManager:update()
	self.logicEngine:update()
	self.timeEngine:update(dt)
	self.audioEngine:update()
	self.scoreEngine:update()
	self.graphicEngine:update(dt)
	self.modifierSequence:update()
end

RhythmModel.setNoteChart = function(self, noteChart)
	assert(noteChart)
	self.modifierSequence.noteChart = noteChart
	self.timeEngine.noteChart = noteChart
	self.scoreEngine.noteChart = noteChart
	self.logicEngine.noteChart = noteChart
	self.graphicEngine.noteChart = noteChart
end

RhythmModel.setNoteSkin = function(self, noteSkin)
	assert(noteSkin)
	self.graphicEngine.noteSkin = noteSkin
end

RhythmModel.setInputBindings = function(self, inputBindings)
	assert(inputBindings)
	self.inputManager:setBindings(inputBindings)
end

return RhythmModel
