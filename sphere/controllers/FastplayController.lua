local class = require("class")
local InputMode = require("ncdk.InputMode")

---@class sphere.FastplayController
---@operator call: sphere.FastplayController
local FastplayController = class()

function FastplayController:play()
	self:load()

	local rhythmModel = self.rhythmModel
	local replayModel = self.replayModel
	local timeEngine = rhythmModel.timeEngine

	timeEngine:play()
	timeEngine.currentTime = math.huge
	replayModel:update()
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()

	self:unload()
end

function FastplayController:load()
	local noteChartModel = self.noteChartModel
	local difficultyModel = self.difficultyModel
	local rhythmModel = self.rhythmModel
	local modifierModel = self.modifierModel
	local replayModel = self.replayModel
	noteChartModel:load()

	local noteChart = noteChartModel:loadNoteChart()

	local state = {}
	state.timeRate = 1
	state.inputMode = InputMode()
	state.inputMode:set(noteChart.inputMode)

	modifierModel:applyMeta(state)
	modifierModel:apply(noteChart)

	rhythmModel:setTimeRate(modifierModel.state.timeRate)
	rhythmModel:setWindUp(modifierModel.state.windUp)
	rhythmModel:setNoteChart(noteChart)
	rhythmModel.noteChart = noteChart

	replayModel.timings = rhythmModel.timings
	rhythmModel.inputManager.observable:add(replayModel)

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

function FastplayController:unload()
	local rhythmModel = self.rhythmModel
	rhythmModel:unloadAllEngines()
end

return FastplayController
