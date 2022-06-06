local Class						= require("aqua.util.Class")

local FastplayController = Class:new()

FastplayController.play = function(self)
	self:load()

	local rhythmModel = self.game.rhythmModel
	local timeEngine = rhythmModel.timeEngine

	timeEngine:resetTimeRate()
	timeEngine:play()
	timeEngine.currentTime = math.huge
	rhythmModel.replayModel.currentTime = math.huge
	rhythmModel.replayModel:update()
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()
	self.game.modifierModel:update()

	self:unload()
end

FastplayController.load = function(self)
	local noteChartModel = self.game.noteChartModel
	local difficultyModel = self.game.difficultyModel
	local rhythmModel = self.game.rhythmModel
	local modifierModel = self.game.modifierModel
	noteChartModel:load()

	local noteChart = noteChartModel:loadNoteChart()
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart

	rhythmModel:load()

	modifierModel:apply("NoteChartModifier")

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
	local rhythmModel = self.game.rhythmModel
	rhythmModel:unloadAllEngines()
	rhythmModel:unload()
end

FastplayController.receive = function(self, event)
	self.game.rhythmModel:receive(event)
end

return FastplayController
