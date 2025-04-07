local class = require("class")
local InputMode = require("ncdk.InputMode")
local ModifierModel = require("sphere.models.ModifierModel")

---@class sphere.FastplayController
---@operator call: sphere.FastplayController
local FastplayController = class()

---@param rhythmModel sphere.RhythmModel
---@param replayModel sphere.ReplayModel
---@param cacheModel sphere.CacheModel
---@param playContext sphere.PlayContext
function FastplayController:new(
	rhythmModel,
	replayModel,
	cacheModel,
	playContext
)
	self.rhythmModel = rhythmModel
	self.replayModel = replayModel
	self.cacheModel = cacheModel
	self.playContext = playContext
end

---@param chart ncdk2.Chart
---@param replay sphere.Replay
---@return table
function FastplayController:applyModifiers(chart, replay)
	local state = {}
	state.inputMode = InputMode(chart.inputMode)

	local modifiers = self.playContext.modifiers
	ModifierModel:applyMeta(modifiers, state)
	ModifierModel:apply(modifiers, chart)

	return state
end

---@param chart ncdk2.Chart
---@param chartmeta sea.Chartmeta
---@param replay sphere.Replay
function FastplayController:play(chart, chartmeta, replay)
	local rhythmModel = self.rhythmModel
	local replayModel = self.replayModel
	local cacheModel = self.cacheModel
	local playContext = self.playContext

	local state = self:applyModifiers(chart, replay)

	rhythmModel:setTimeRate(playContext.rate)
	rhythmModel:setWindUp(state.windUp)
	rhythmModel:setNoteChart(chart, chartmeta)

	replayModel:setMode("replay")
	rhythmModel.inputManager:setMode("internal")
	rhythmModel.inputManager.observable:add(replayModel)

	rhythmModel:load()

	local chartdiff = {
		rate = playContext.rate,
		inputmode = tostring(chart.inputMode),
		notes_preview = "",  -- do not generate preview
	}
	cacheModel.chartdiffGenerator.difficultyModel:compute(chartdiff, chart, playContext.rate)

	chartdiff.modifiers = playContext.modifiers
	playContext.chartdiff = chartdiff
	chart.chartdiff = chartdiff

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
