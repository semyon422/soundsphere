local Class						= require("aqua.util.Class")

local FastplayController = Class:new()

FastplayController.play = function(self)
	self:loadTimePoints()
	self:load()

	local rhythmModel = self.gameController.rhythmModel
	local timeEngine = rhythmModel.timeEngine
	local absoluteTimeList = self.absoluteTimeList
	for i = 1, #absoluteTimeList do
		local time = absoluteTimeList[i]
		timeEngine.currentTime = time
		timeEngine.exactCurrentTime = time
		timeEngine:sendState()
		self:update()
		rhythmModel.replayModel:update()
		self:update()
	end

	self:unload()
end

FastplayController.load = function(self)
	local noteChartModel = self.gameController.noteChartModel
	local difficultyModel = self.gameController.difficultyModel
	local rhythmModel = self.gameController.rhythmModel
	noteChartModel:load()

	local noteChart = noteChartModel:loadNoteChart()
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart

	rhythmModel:load()
	rhythmModel:loadLogicEngines()

	local scoreEngine = rhythmModel.scoreEngine

	local enps, averageStrain, generalizedKeymode = difficultyModel:getDifficulty(noteChart)
	scoreEngine.baseEnps = enps
	scoreEngine.baseAverageStrain = averageStrain
	scoreEngine.generalizedKeymode = generalizedKeymode

	self.gameController.rhythmModel.timeEngine:setTimeRate(rhythmModel.timeEngine:getBaseTimeRate())
end

FastplayController.unload = function(self)
	local rhythmModel = self.gameController.rhythmModel
	rhythmModel:unloadAllEngines()
	rhythmModel:unload()
end

FastplayController.update = function(self, dt)
	local rhythmModel = self.gameController.rhythmModel
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()
	rhythmModel.modifierModel:update()
end

FastplayController.draw = function(self)
end

FastplayController.receive = function(self, event)
	self.gameController.rhythmModel:receive(event)
end

FastplayController.loadTimePoints = function(self)
	local absoluteTimes = {}

	local events = self.gameController.rhythmModel.replayModel.replay.events
	for i = 1, #events do
		absoluteTimes[events[i].time] = true
	end

	local absoluteTimeList = {}
	for time in pairs(absoluteTimes) do
		absoluteTimeList[#absoluteTimeList + 1] = time
	end
	table.sort(absoluteTimeList)
	absoluteTimeList[#absoluteTimeList + 1] = math.huge

	self.absoluteTimeList = absoluteTimeList
	self.nextTimeIndex = 1
end

return FastplayController
