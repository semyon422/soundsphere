local class = require("class")
local thread = require("thread")
local simplify_notechart = require("libchart.simplify_notechart")
local Timings = require("sea.chart.Timings")
local Healths = require("sea.chart.Healths")
local Subtimings = require("sea.chart.Subtimings")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")

---@class sphere.ResultController
---@operator call: sphere.ResultController
local ResultController = class()

---@param selectModel sphere.SelectModel
---@param replayModel sphere.ReplayModel
---@param rhythmModel sphere.RhythmModel
---@param onlineModel sphere.OnlineModel
---@param configModel sphere.ConfigModel
---@param computeContext sea.ComputeContext
function ResultController:new(
	selectModel,
	replayModel,
	rhythmModel,
	onlineModel,
	configModel,
	computeContext,
	replayBase
)
	self.selectModel = selectModel
	self.replayModel = replayModel
	self.rhythmModel = rhythmModel
	self.onlineModel = onlineModel
	self.configModel = configModel
	self.computeContext = computeContext
	self.replayBase = replayBase
end

function ResultController:load()
	self.selectModel:pullScore()

	local selectModel = self.selectModel
	local scoreItemIndex = selectModel.scoreItemIndex
	local scoreItem = selectModel.scoreItem
	if not scoreItem then
		return
	end

	self.selectModel:scrollScore(nil, scoreItemIndex)
end

function ResultController:unload()
	local config = self.configModel.configs.select
	config.chartplay_id = config.select_chartplay_id
end

local readAsync = thread.async(function(...) return love.filesystem.read(...) end)

---@param chartplay sea.Chartplay
---@return string?
function ResultController:getReplayDataAsync(chartplay)
	---@type string?
	local content
	if chartplay.user_name then
		local remote = self.onlineModel.authManager.sea_client.remote
		content = remote.submission:getReplayFile(chartplay.replay_hash)
	elseif chartplay.replay_hash then
		content = readAsync(self.replayModel.path .. "/" .. chartplay.replay_hash)
	end

	return content
end

---@param mode string
---@param chartplay sea.Chartplay
---@return boolean?
function ResultController:replayNoteChartAsync(mode, chartplay)
	if not chartplay or not self.selectModel:notechartExists() then
		return
	end

	local content = self:getReplayDataAsync(chartplay)
	if not content then
		return
	end

	local replayModel = self.replayModel

	local replay = replayModel:loadReplay(content)
	if not replay then
		return
	end

	local rhythmModel = self.rhythmModel

	if mode == "retry" then
		rhythmModel.inputManager:setMode("external")
		replayModel:setMode("record")
		return
	end

	local computeContext = self.computeContext

	computeContext.chartplay = chartplay
	rhythmModel:setReplayBase(replay)
	replayModel:decodeEvents(replay.events)

	rhythmModel.inputManager:setMode("internal")
	replayModel:setMode("replay")

	if mode == "replay" then
		return
	end

	local chartview = self.selectModel.chartview

	local data = assert(love.filesystem.read(chartview.location_path))
	local chart_chartmeta = assert(computeContext:fromFileData(chartview.chartfile_name, data, chartview.index))
	local chart, chartmeta = chart_chartmeta.chart, chart_chartmeta.chartmeta

	computeContext:applyModifierReorder(replay)
	computeContext:computeBase(replay)
	computeContext:computePlay(rhythmModel, replayModel)

	self:actualizeReplayBase()
	self.rhythmModel.scoreEngine:createByTimings(self.replayBase.timings, self.replayBase.subtimings, true)

	if self.configModel.configs.settings.miscellaneous.generateGifResult then
		local GifResult = require("libchart.GifResult")
		local gif_result = GifResult()
		gif_result:setBackgroundData(love.filesystem.read(self.selectModel:getBackgroundPath()))
		local data = gif_result:create(
			self.selectModel.chartview,
			chartplay,
			simplify_notechart(chart, {"tap", "hold", "laser"}),
			chart.inputMode:getColumns()
		)
		love.filesystem.write("userdata/result.gif", data)
	end

	rhythmModel.inputManager:setMode("external")
	replayModel:setMode("record")

	return true
end

---@param timings sea.Timings
function ResultController:setReplayBaseTimings(timings)
	local replayBase = self.replayBase
	local settings = self.configModel.configs.settings

	---@type sea.Subtimings?
	local subtimings
	local subtimings_config = settings.subtimings[timings.name]
	if subtimings_config then
		local name = subtimings_config[1]
		local value = subtimings_config[name]
		subtimings = Subtimings(name, value)
	end

	replayBase.timings = timings
	replayBase.subtimings = subtimings
	replayBase.timing_values = assert(TimingValuesFactory:get(timings, subtimings))
end

function ResultController:actualizeReplayBaseTimings()
	local chartmeta = assert(self.computeContext.chartmeta)
	local settings = self.configModel.configs.settings

	local timings = chartmeta.timings
	timings = timings or Timings(unpack(settings.format_timings[chartmeta.format]))
	self:setReplayBaseTimings(timings)
end

function ResultController:actualizeReplayBase()
	local config = self.configModel.configs.settings.replay_base

	if config.auto_timings then
		self:actualizeReplayBaseTimings()
	end
end

return ResultController
