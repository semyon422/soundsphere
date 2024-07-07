local class = require("class")
local thread = require("thread")
local ModifierModel = require("sphere.models.ModifierModel")

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

	self.playContext:load(replay)

	if mode == "retry" then
		rhythmModel.inputManager:setMode("external")
		replayModel:setMode("record")
		return
	end

	self.playContext.scoreEntry = scoreEntry
	rhythmModel:setTimings(replay.timings)
	replayModel.replay = replay

	rhythmModel.inputManager:setMode("internal")
	replayModel:setMode("replay")

	if mode == "replay" then
		return
	end

	local noteChart = self.selectModel:loadChart()
	self.fastplayController:play(noteChart, replay)

	rhythmModel.inputManager:setMode("external")
	replayModel:setMode("record")

	return true
end

return ResultController
