local class = require("class")
local InputMode = require("ncdk.InputMode")
local ModifierModel = require("sphere.models.ModifierModel")

---@class sphere.FastplayController
---@operator call: sphere.FastplayController
local FastplayController = class()

FastplayController.need_preview = false

---@param rhythmModel sphere.RhythmModel
---@param replayModel sphere.ReplayModel
---@param difficultyModel sphere.DifficultyModel
function FastplayController:new(
	rhythmModel,
	replayModel,
	difficultyModel
)
	self.rhythmModel = rhythmModel
	self.replayModel = replayModel
	self.difficultyModel = difficultyModel
end

---@param chart ncdk2.Chart
---@param modifiers sea.Modifier[]
---@return table
function FastplayController:applyModifiers(chart, modifiers)
	local state = {}
	state.inputMode = InputMode(chart.inputMode)

	ModifierModel:applyMeta(modifiers, state)
	ModifierModel:apply(modifiers, chart)

	return state
end

---@param chart ncdk2.Chart
---@param chartmeta sea.Chartmeta
---@param replay sea.Replay
function FastplayController:play(chart, chartmeta, replay)
	local rhythmModel = self.rhythmModel
	local replayModel = self.replayModel

	local chartdiff = {
		rate = replay.rate,
		inputmode = tostring(chart.inputMode),
		notes_preview = "",  -- do not generate preview
	}
	if self.need_preview then
		chartdiff.notes_preview = nil
	end
	self.difficultyModel:compute(chartdiff, chart, replay.rate)

	local state = self:applyModifiers(chart, replay.modifiers)

	rhythmModel:setWindUp(state.windUp)
	rhythmModel:setNoteChart(chart, chartmeta, chartdiff)
	rhythmModel:setPlayTime(chartdiff.start_time, chartdiff.duration)

	replayModel:setMode("replay")
	rhythmModel.inputManager:setMode("internal")
	rhythmModel.inputManager.observable:add(replayModel)

	rhythmModel:load()

	chartdiff.modifiers = replay.modifiers

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
