local class = require("class")
local thread = require("thread")
local simplify_notechart = require("libchart.simplify_notechart")

---@class sphere.ResultController
---@operator call: sphere.ResultController
local ResultController = class()

---@param selectModel sphere.SelectModel
---@param replayModel sphere.ReplayModel
---@param rhythmModel sphere.RhythmModel
---@param onlineModel sphere.OnlineModel
---@param configModel sphere.ConfigModel
---@param fastplayController sphere.FastplayController
function ResultController:new(
	selectModel,
	replayModel,
	rhythmModel,
	onlineModel,
	configModel,
	fastplayController
)
	self.selectModel = selectModel
	self.replayModel = replayModel
	self.rhythmModel = rhythmModel
	self.onlineModel = onlineModel
	self.configModel = configModel
	self.fastplayController = fastplayController
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
	config.score_id = config.select_score_id
end

local readAsync = thread.async(function(...) return love.filesystem.read(...) end)

---@param scoreEntry table
---@return string?
function ResultController:getReplayDataAsync(scoreEntry)
	local replayModel = self.replayModel
	local webApi = self.onlineModel.webApi

	local content
	if scoreEntry.file then
		content = webApi.api.files[scoreEntry.file.id]:__get({download = true})
	elseif scoreEntry.replay_hash then
		content = readAsync(replayModel.path .. "/" .. scoreEntry.replay_hash)
	end

	return content
end

---@param mode string
---@param scoreEntry table
---@return boolean?
function ResultController:replayNoteChartAsync(mode, scoreEntry)
	if not scoreEntry or not self.selectModel:notechartExists() then
		return
	end

	local content = self:getReplayDataAsync(scoreEntry)
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

	rhythmModel.scoreEntry = scoreEntry
	rhythmModel:setTimings(replay.timing_values)
	replayModel:decodeEvents(replay.events)

	rhythmModel.inputManager:setMode("internal")
	replayModel:setMode("replay")

	if mode == "replay" then
		return
	end

	local chart, chartmeta = self.selectModel:loadChartAbsolute()
	self.fastplayController:play(chart, chartmeta, replay)

	if self.configModel.configs.settings.miscellaneous.generateGifResult then
		local GifResult = require("libchart.GifResult")
		local gif_result = GifResult()
		gif_result:setBackgroundData(love.filesystem.read(self.selectModel:getBackgroundPath()))
		local data = gif_result:create(
			self.selectModel.chartview,
			scoreEntry,
			simplify_notechart(chart, {"note", "hold", "laser"}),
			chart.inputMode:getColumns()
		)
		love.filesystem.write("userdata/result.gif", data)
	end

	rhythmModel.inputManager:setMode("external")
	replayModel:setMode("record")

	return true
end

return ResultController
