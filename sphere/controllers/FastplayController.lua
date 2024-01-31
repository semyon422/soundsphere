local class = require("class")
local InputMode = require("ncdk.InputMode")
local ModifierModel = require("sphere.models.ModifierModel")

---@class sphere.FastplayController
---@operator call: sphere.FastplayController
local FastplayController = class()

---@param noteChart ncdk.NoteChart
---@param replay sphere.Replay
---@return table
function FastplayController:applyModifiers(noteChart, replay)
	local state = {}
	state.inputMode = InputMode(noteChart.inputMode)

	local modifiers = self.playContext.modifiers
	ModifierModel:applyMeta(modifiers, state)
	ModifierModel:apply(modifiers, noteChart)

	return state
end

---@param noteChart ncdk.NoteChart
---@param replay sphere.Replay
function FastplayController:play(noteChart, replay)
	local rhythmModel = self.rhythmModel
	local replayModel = self.replayModel
	local cacheModel = self.cacheModel
	local playContext = self.playContext

	local state = self:applyModifiers(noteChart, replay)

	rhythmModel:setTimeRate(playContext.rate)
	rhythmModel:setWindUp(state.windUp)
	rhythmModel:setNoteChart(noteChart)

	replayModel:setMode("replay")
	rhythmModel.inputManager:setMode("internal")
	rhythmModel.inputManager.observable:add(replayModel)

	rhythmModel:load()

	local chartdiff = cacheModel.chartdiffGenerator:compute(noteChart, playContext.rate)
	chartdiff.modifiers = playContext.modifiers
	playContext.chartdiff = chartdiff

	rhythmModel.timeEngine:sync(0)
	rhythmModel:loadLogicEngines()
	replayModel:load()

	rhythmModel.timeEngine:play()
	rhythmModel.timeEngine.currentTime = math.huge
	replayModel:update()
	rhythmModel.logicEngine:update()
	rhythmModel.scoreEngine:update()

	rhythmModel:unloadAllEngines()
end

return FastplayController
