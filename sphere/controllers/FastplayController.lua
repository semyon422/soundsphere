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
	local modifierModel = rhythmModel.modifierModel
	noteChartModel:load()

	local noteChart = noteChartModel:loadNoteChart()
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart

	rhythmModel:load()

	modifierModel:apply("NoteChartModifier")
	modifierModel:apply("TimeEngineModifier")
	modifierModel:apply("ScoreEngineModifier")
	modifierModel:apply("LogicEngineModifier")

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
