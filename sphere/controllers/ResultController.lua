local Class = require("Class")
local thread = require("thread")

local ResultController = Class:new()

ResultController.load = function(self)
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

ResultController.replayNoteChartAsync = function(self, mode, scoreEntry)
	if not self.selectModel:notechartExists() then
		return
	end

	local replayModel = self.replayModel
	local rhythmModel = self.rhythmModel
	local modifierModel = self.modifierModel
	local webApi = self.onlineModel.webApi

	local content
	if scoreEntry.file then
		content = webApi.api.files[scoreEntry.file.id]:__get({download = true})
	elseif scoreEntry.replayHash then
		content = readAsync(replayModel.path .. "/" .. scoreEntry.replayHash)
	end
	local replay = replayModel:loadReplay(content)

	if replay.modifiers then
		modifierModel:setConfig(replay.modifiers)
		modifierModel:fixOldFormat(replay.modifiers)
	end

	if mode == "replay" or mode == "result" then
		rhythmModel.timings = replay.timings
		rhythmModel.scoreEngine.scoreEntry = scoreEntry
		self.replayModel.replay = replay
		rhythmModel.inputManager:setMode("internal")
		self.replayModel:setMode("replay")
	elseif mode == "retry" then
		rhythmModel.inputManager:setMode("external")
		self.replayModel:setMode("record")
	end

	if mode ~= "result" then
		return
	end

	self.fastplayController:play()

	rhythmModel.scoreEngine.scoreEntry = scoreEntry
	local config = self.configModel.configs.select
	config.scoreEntryId = scoreEntry.id
	rhythmModel.inputManager:setMode("external")
	self.replayModel:setMode("record")

	return true
end

ResultController.replayNoteChart = thread.coro(ResultController.replayNoteChartAsync)

return ResultController
