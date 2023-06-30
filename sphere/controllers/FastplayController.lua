local Class						= require("Class")

local FastplayController = Class:new()

FastplayController.play = function(self)
	self:load()

	local rhythmModel = self.rhythmModel
	local replayModel = self.replayModel
	local timeEngine = rhythmModel.timeEngine

	timeEngine:play()
	timeEngine.currentTime = math.huge
	replayModel.currentTime = math.huge
	replayModel:update()
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()

	self:unload()
end

FastplayController.load = function(self)
	local noteChartModel = self.noteChartModel
	local difficultyModel = self.difficultyModel
	local rhythmModel = self.rhythmModel
	local modifierModel = self.modifierModel
	noteChartModel:load()

	local noteChart = noteChartModel:loadNoteChart()

	modifierModel:apply(noteChart)

	rhythmModel:setTimeRate(modifierModel.state.timeRate)
	rhythmModel:setWindUp(modifierModel.state.windUp)
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart

	rhythmModel:load()

	local scoreEngine = rhythmModel.scoreEngine

	local enps, longNoteRatio, longNoteArea = difficultyModel:getDifficulty(noteChart)
	scoreEngine.baseEnps = enps
	scoreEngine.longNoteRatio = longNoteRatio
	scoreEngine.longNoteArea = longNoteArea

	scoreEngine.noteChartDataEntry = noteChartModel.noteChartDataEntry

	rhythmModel.timeEngine:sync({
		time = 0,
		dt = 0,
	})
	rhythmModel:loadLogicEngines()
	self.replayModel:load()
end

FastplayController.unload = function(self)
	local rhythmModel = self.rhythmModel
	rhythmModel:unloadAllEngines()
	rhythmModel:unload()
end

return FastplayController
