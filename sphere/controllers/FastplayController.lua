local Class						= require("aqua.util.Class")

local FastplayController = Class:new()

FastplayController.play = function(self)
	self:load()

	local rhythmModel = self.gameController.rhythmModel
	local timeEngine = rhythmModel.timeEngine

	timeEngine:resetTimeRate()
	timeEngine:play()
	timeEngine.currentTime = math.huge
	rhythmModel.replayModel.currentTime = math.huge
	rhythmModel.replayModel:update()
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()
	rhythmModel.modifierModel:update()

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

	local scoreEngine = rhythmModel.scoreEngine

	local enps, averageStrain, generalizedKeymode = difficultyModel:getDifficulty(noteChart)
	scoreEngine.baseEnps = enps
	scoreEngine.baseAverageStrain = averageStrain
	scoreEngine.generalizedKeymode = generalizedKeymode

	scoreEngine.noteChartDataEntry = noteChartModel.noteChartDataEntry

	rhythmModel:load()
	rhythmModel.timeEngine:sync({
		time = 0,
		dt = 0,
	})
	rhythmModel:loadLogicEngines()
end

FastplayController.unload = function(self)
	local rhythmModel = self.gameController.rhythmModel
	rhythmModel:unloadAllEngines()
	rhythmModel:unload()
end

FastplayController.receive = function(self, event)
	self.gameController.rhythmModel:receive(event)
end

return FastplayController
