local Class				= require("aqua.util.Class")

local ResultController = Class:new()

ResultController.load = function(self)
	local modifierModel = self.gameController.modifierModel
	local themeModel = self.gameController.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ResultView")
	self.view = view

	view.modifierModel = modifierModel
	view.controller = self

	view.rhythmModel = self.rhythmModel
	view.noteChartModel = self.gameController.noteChartModel
	view.selectModel = self.gameController.selectModel
	view.scoreLibraryModel = self.gameController.scoreLibraryModel
	view.configModel = self.gameController.configModel
	view.backgroundModel = self.gameController.backgroundModel

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
		self.gameController.modifierModel.config = self.gameController.configModel:getConfig("modifier")
		self.gameController.screenManager:set(self.selectController)
	elseif event.name == "loadScore" then
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
	local replay = gameplayController.rhythmModel.replayModel:loadReplay(hash)

	local modifierModel = self.gameController.modifierModel
	modifierModel.config = modifierModel:decode(scoreEntry.modifiers)
	if #modifierModel.config == 0 then
		modifierModel.config = replay.modifiers
		modifierModel:fixOldFormat(replay.modifiers)
	end

	if mode == "replay" or mode == "result" then
		gameplayController.rhythmModel.scoreEngine.scoreEntry = scoreEntry
		gameplayController.rhythmModel.replayModel.replay = replay
		gameplayController.rhythmModel.inputManager:setMode("internal")
		gameplayController.rhythmModel.replayModel:setMode("replay")
	elseif mode == "retry" then
		gameplayController.rhythmModel.inputManager:setMode("external")
		gameplayController.rhythmModel.replayModel:setMode("record")
	end

	gameplayController.selectController = self.gameController.selectController
	gameplayController.gameController = self.gameController

	if mode == "result" then
		gameplayController:play()

		self.rhythmModel = gameplayController.rhythmModel
		local view = self.view
		if view then
			view.rhythmModel = self.rhythmModel
			view:unload()
			view:load()
		end

		gameplayController.rhythmModel.scoreEngine.scoreEntry = scoreEntry
		local config = self.gameController.configModel:getConfig("select")
		config.scoreEntryId = scoreEntry.id
		if itemIndex then
			self.gameController.selectModel:scrollScore(nil, itemIndex)
		end
	else
		return self.gameController.screenManager:set(gameplayController)
	end
end

return ResultController
