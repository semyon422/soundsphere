local class = require("class")
local thread = require("thread")

---@class sphere.ResultController
---@operator call: sphere.ResultController
local ResultController = class()

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

local readAsync = thread.async(function(...) return love.filesystem.read(...) end)

---@param scoreEntry table
---@return string?
function ResultController:getReplayDataAsync(scoreEntry)
	local replayModel = self.replayModel
	local webApi = self.onlineModel.webApi

	local content
	if scoreEntry.file then
		content = webApi.api.files[scoreEntry.file.id]:__get({download = true})
	elseif scoreEntry.replayHash then
		content = readAsync(replayModel.path .. "/" .. scoreEntry.replayHash)
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
	local modifierModel = self.modifierModel

	if replay.modifiers then
		modifierModel:setConfig(replay.modifiers)
		modifierModel:fixOldFormat(replay.modifiers)
	end

	if mode == "retry" then
		rhythmModel.inputManager:setMode("external")
		replayModel:setMode("record")
		return
	end

	rhythmModel.timings = replay.timings
	rhythmModel.scoreEngine.scoreEntry = scoreEntry
	replayModel.replay = replay

	rhythmModel.inputManager:setMode("internal")
	replayModel:setMode("replay")

	if mode == "replay" then
		return
	end

	local noteChart = self.selectModel:loadNoteChart()
	self.fastplayController:play(noteChart, replay)

	local config = self.configModel.configs.select
	config.scoreEntryId = scoreEntry.id

	rhythmModel.scoreEngine.scoreEntry = scoreEntry

	rhythmModel.inputManager:setMode("external")
	replayModel:setMode("record")

	return true
end

return ResultController
