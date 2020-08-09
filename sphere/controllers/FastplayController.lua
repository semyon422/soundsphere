local Class						= require("aqua.util.Class")
local ScreenManager				= require("sphere.screen.ScreenManager")
local RhythmModel				= require("sphere.models.RhythmModel")
local NoteChartModel			= require("sphere.models.NoteChartModel")

local FastplayController = Class:new()

FastplayController.construct = function(self)
	self.noteChartModel = NoteChartModel:new()
	self.rhythmModel = RhythmModel:new()
end

FastplayController.play = function(self)
	self:loadTimePoints()
	self:load()

	local timeEngine = self.rhythmModel.timeEngine
	local absoluteTimeList = self.absoluteTimeList
	for i = 1, #absoluteTimeList do
		local time = absoluteTimeList[i]
		timeEngine.currentTime = time
		timeEngine.exactCurrentTime = time
		timeEngine:sendState()
		self:update()
		self.rhythmModel.replayModel:update()
		self:update()
	end

	self:unload()
end

FastplayController.load = function(self)
	local noteChartModel = self.noteChartModel
	local rhythmModel = self.rhythmModel

	noteChartModel:load()

	local noteChart = noteChartModel:getNoteChart()
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart

	local modifierModel = rhythmModel.modifierModel

	modifierModel:load()

	modifierModel:apply("NoteChartModifier")

	rhythmModel.timeEngine:load()
	modifierModel:apply("TimeEngineModifier")

	rhythmModel.scoreEngine:load()
	modifierModel:apply("ScoreEngineModifier")

	modifierModel:apply("LogicEngineModifier")

	rhythmModel.logicEngine:load()
	rhythmModel.replayModel:load()

	self.rhythmModel.timeEngine:setTimeRate(self.rhythmModel.timeEngine:getBaseTimeRate())
end

FastplayController.unload = function(self)
	self.rhythmModel:unload()
end

FastplayController.update = function(self, dt)
	local rhythmModel = self.rhythmModel
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()
	rhythmModel.modifierModel:update()
end

FastplayController.draw = function(self)
end

FastplayController.receive = function(self, event)
	self.rhythmModel:receive(event)
end

FastplayController.loadTimePoints = function(self)
	local absoluteTimes = {}

	local events = self.rhythmModel.replayModel.replay.events
	for i = 1, #events do
		absoluteTimes[events[i].time] = true
	end

	local absoluteTimeList = {}
	for time in pairs(absoluteTimes) do
		absoluteTimeList[#absoluteTimeList + 1] = time
	end
	table.sort(absoluteTimeList)

	self.absoluteTimeList = absoluteTimeList
	self.nextTimeIndex = 1
end

return FastplayController
