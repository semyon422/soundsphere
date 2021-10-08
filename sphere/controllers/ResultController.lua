local Class				= require("aqua.util.Class")

local ResultController = Class:new()

ResultController.oldTimings = {
	normalscore = 0.12,
	ShortScoreNote = {
		hit = {-0.12, 0.12},
		miss = {-0.16, 0.12}
	},
	LongScoreNote = {
		startHit = {-0.12, 0.12},
		startMiss = {-0.16, 0.12},
		endHit = {-0.12, 0.12},
		endMiss = {-0.16, 0.12}
	}
}

ResultController.load = function(self)
	local themeModel = self.gameController.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ResultView")
	self.view = view

	view.controller = self
	view.gameController = self.gameController

	view:load()
end

ResultController.unload = function(self)
	self.view:unload()
end

ResultController.update = function(self, dt)
	self.view:update(dt)
end

ResultController.draw = function(self)
	self.view:draw()
end

ResultController.resetConfigs = function(self)
	self.gameController.modifierModel.config = self.gameController.configModel.configs.modifier
	self.gameController.rhythmModel.timings = self.gameController.configModel.configs.timings
end

ResultController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "changeScreen" then
		self:resetConfigs()
		self.gameController.screenManager:set(self.selectController)
	elseif event.name == "loadScore" then
		self:resetConfigs()
		self:replayNoteChart(event.mode, event.scoreEntry, event.itemIndex)
	elseif event.name == "scrollScore" then
		self.gameController.selectModel:scrollScore(event.direction)
	end
end

ResultController.replayNoteChart = function(self, mode, scoreEntry, itemIndex)
	local noteChartModel = self.gameController.noteChartModel
	if not noteChartModel:getFileInfo() then
		return
	end
	if noteChartModel.noteChartDataEntry.hash == "" then
		return
	end

	local gameplayController
	if mode == "result" then
		local FastplayController = require("sphere.controllers.FastplayController")
		gameplayController = FastplayController:new()
	else
		local GameplayController = require("sphere.controllers.GameplayController")
		gameplayController = GameplayController:new()
	end

	local hash = scoreEntry.replayHash
	local rhythmModel = self.gameController.rhythmModel
	local replay = rhythmModel.replayModel:loadReplay(hash)

	local modifierModel = self.gameController.modifierModel
	modifierModel.config = modifierModel:decode(scoreEntry.modifiers)
	if #modifierModel.config == 0 and replay.modifiers then
		modifierModel.config = replay.modifiers
		modifierModel:fixOldFormat(replay.modifiers)
	end

	if mode == "replay" or mode == "result" then
		if replay.timings then
			rhythmModel.timings = replay.timings
		else
			rhythmModel.timings = self.oldTimings
		end
		rhythmModel.scoreEngine.scoreEntry = scoreEntry
		rhythmModel.replayModel.replay = replay
		rhythmModel.inputManager:setMode("internal")
		rhythmModel.replayModel:setMode("replay")
	elseif mode == "retry" then
		rhythmModel.inputManager:setMode("external")
		rhythmModel.replayModel:setMode("record")
	end

	gameplayController.selectController = self.gameController.selectController
	gameplayController.gameController = self.gameController

	if mode == "result" then
		gameplayController:play()

		local view = self.view
		if view then
			view:unload()
			view:load()
		end

		rhythmModel.scoreEngine.scoreEntry = scoreEntry
		local config = self.gameController.configModel.configs.select
		config.scoreEntryId = scoreEntry.id
		if itemIndex then
			self.gameController.selectModel:scrollScore(nil, itemIndex)
		end
		rhythmModel.inputManager:setMode("external")
		rhythmModel.replayModel:setMode("record")
	else
		return self.gameController.screenManager:set(gameplayController)
	end
end

return ResultController
