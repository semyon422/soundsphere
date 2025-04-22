local class = require("class")

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

---@param computeContext sea.ComputeContext
---@param replay sea.Replay
function FastplayController:play(computeContext, replay)
	local rhythmModel = self.rhythmModel
	local replayModel = self.replayModel

	local chart = assert(computeContext.chart)
	local chartmeta = assert(computeContext.chartmeta)
	local chartdiff, state = computeContext:computeChartdiff(replay)
	computeContext:applyColumnOrder(replay.columns_order)
	if replay.tap_only then
		computeContext:applyTapOnly()
	end

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
