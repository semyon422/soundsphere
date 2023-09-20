local class = require("class")
local InputMode = require("ncdk.InputMode")

---@class sphere.FastplayController
---@operator call: sphere.FastplayController
local FastplayController = class()

---@param noteChart ncdk.NoteChart
---@param replay sphere.Replay
---@return table
function FastplayController:applyModifiers(noteChart, replay)
	local modifierModel = self.modifierModel

	local state = {}
	state.timeRate = 1
	state.inputMode = InputMode()
	state.inputMode:set(noteChart.inputMode)

	-- if replay.modifiers then
	-- 	modifierModel:setConfig(replay.modifiers)
	-- 	modifierModel:fixOldFormat(replay.modifiers)
	-- end

	modifierModel:applyMeta(state)
	modifierModel:apply(noteChart)

	return state
end

---@param noteChart ncdk.NoteChart
---@param replay sphere.Replay
function FastplayController:play(noteChart, replay)
	local difficultyModel = self.difficultyModel
	local rhythmModel = self.rhythmModel
	local replayModel = self.replayModel

	local state = self:applyModifiers(noteChart, replay)

	rhythmModel.timings = replay.timings
	replayModel.replay = replay

	rhythmModel:setTimeRate(state.timeRate)
	rhythmModel:setWindUp(state.windUp)
	rhythmModel:setNoteChart(noteChart)

	replayModel:setMode("replay")
	rhythmModel.inputManager:setMode("internal")
	rhythmModel.inputManager.observable:add(replayModel)

	rhythmModel:load()

	local scoreEngine = rhythmModel.scoreEngine

	local enps, longNoteRatio, longNoteArea = difficultyModel:getDifficulty(noteChart)
	scoreEngine.baseEnps = enps
	scoreEngine.longNoteRatio = longNoteRatio
	scoreEngine.longNoteArea = longNoteArea

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
