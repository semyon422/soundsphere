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

ResultController.load = function(self)
	local themeModel = self.game.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ResultView")
	self.view = view

	view.controller = self
	view.game = self.game

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

ResultController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "changeScreen" then
		self.game:resetGameplayConfigs()
		self.game.screenManager:set(self.selectController)
	elseif event.name == "loadScore" then
		self.game:resetGameplayConfigs()
		self:replayNoteChart(event.mode, event.scoreEntry, event.itemIndex)
	elseif event.name == "scrollScore" then
		self.game.selectModel:scrollScore(event.direction)
	end
end

ResultController.replayNoteChart = function(self, mode, scoreEntry, itemIndex)
	local noteChartModel = self.game.noteChartModel
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
	local rhythmModel = self.game.rhythmModel
	local replay = rhythmModel.replayModel:loadReplay(hash)

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
		rhythmModel.replayModel.replay = replay
		rhythmModel.inputManager:setMode("internal")
		rhythmModel.replayModel:setMode("replay")
	elseif mode == "retry" then
		rhythmModel.inputManager:setMode("external")
		rhythmModel.replayModel:setMode("record")
	end

	gameplayController.selectController = self.game.selectController
	gameplayController.game = self.game

	if mode == "result" then
		gameplayController:play()

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
		rhythmModel.replayModel:setMode("record")
	else
		return self.game.screenManager:set(gameplayController)
	end
end

return ResultController
