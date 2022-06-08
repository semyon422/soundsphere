local Class				= require("aqua.util.Class")

local ResultController = Class:new()

ResultController.oldTimings = {
	ShortNote = {
		hit = {-0.12, 0.12},
		miss = {-0.16, 0.12}
	},
	LongNoteStart = {
		hit = {-0.12, 0.12},
		miss = {-0.16, 0.12},
	},
	LongNoteEnd = {
		hit = {-0.12, 0.12},
		miss = {-0.16, 0.12}
	}
}

ResultController.replaySelectedNoteChart = function(self)
	local selectModel = self.game.selectModel
	local scoreItemIndex = selectModel.scoreItemIndex
	local scoreItem = selectModel.scoreItem
	if not scoreItem then
		return
	end

	self:replayNoteChart("result", scoreItem, scoreItemIndex)
end

ResultController.replayNoteChart = function(self, mode, scoreEntry, itemIndex)
	local noteChartModel = self.game.noteChartModel
	if not noteChartModel:getFileInfo() then
		return
	end
	if noteChartModel.noteChartDataEntry.hash == "" then
		return
	end

	local hash = scoreEntry.replayHash
	local rhythmModel = self.game.rhythmModel
	local replay = self.game.replayModel:loadReplay(hash)

	local modifierModel = self.game.modifierModel
	modifierModel:setConfig(modifierModel:decode(scoreEntry.modifiers))
	if #modifierModel.config == 0 and replay.modifiers then
		modifierModel:setConfig(replay.modifiers)
		modifierModel:fixOldFormat(replay.modifiers, not replay.timings)
	end

	if mode == "replay" or mode == "result" then
		if replay.timings then
			rhythmModel.timings = replay.timings
		else
			rhythmModel.timings = self.oldTimings
		end
		rhythmModel.scoreEngine.scoreEntry = scoreEntry
		self.game.replayModel.replay = replay
		rhythmModel.inputManager:setMode("internal")
		self.game.replayModel:setMode("replay")
	elseif mode == "retry" then
		rhythmModel.inputManager:setMode("external")
		self.game.replayModel:setMode("record")
	end

	if mode ~= "result" then
		return
	end

	self.game.fastplayController:play()

	local view = self.view
	if view then
		view:unload()
		view:load()
	end

	rhythmModel.scoreEngine.scoreEntry = scoreEntry
	local config = self.game.configModel.configs.select
	config.scoreEntryId = scoreEntry.id
	if itemIndex then
		self.game.selectModel:scrollScore(nil, itemIndex)
	end
	rhythmModel.inputManager:setMode("external")
	self.game.replayModel:setMode("record")

	return true
end

return ResultController
