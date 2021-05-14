local Class					= require("aqua.util.Class")
local NoteChartSetLibraryModel		= require("sphere.models.NoteChartSetLibraryModel")
local NoteChartLibraryModel		= require("sphere.models.NoteChartLibraryModel")
local ScoreLibraryModel		= require("sphere.models.ScoreLibraryModel")
local SearchModel		= require("sphere.models.SearchModel")
local SelectModel		= require("sphere.models.SelectModel")
local PreviewModel		= require("sphere.models.PreviewModel")

local SelectController = Class:new()

SelectController.construct = function(self)
	self.noteChartSetLibraryModel = NoteChartSetLibraryModel:new()
	self.noteChartLibraryModel = NoteChartLibraryModel:new()
	self.scoreLibraryModel = ScoreLibraryModel:new()
	self.searchModel = SearchModel:new()
	self.selectModel = SelectModel:new()
	self.previewModel = PreviewModel:new()
end

SelectController.load = function(self)
	local noteChartSetLibraryModel = self.noteChartSetLibraryModel
	local noteChartLibraryModel = self.noteChartLibraryModel
	local scoreLibraryModel = self.scoreLibraryModel
	local searchModel = self.searchModel
	local selectModel = self.selectModel
	local previewModel = self.previewModel

	local modifierModel = self.gameController.modifierModel
	local noteSkinModel = self.gameController.noteSkinModel
	local noteChartModel = self.gameController.noteChartModel
	local inputModel = self.gameController.inputModel
	local cacheModel = self.gameController.cacheModel
	local themeModel = self.gameController.themeModel
	local configModel = self.gameController.configModel
	local mountModel = self.gameController.mountModel
	local scoreModel = self.gameController.scoreModel
	local onlineModel = self.gameController.onlineModel
	local difficultyModel = self.gameController.difficultyModel
	local backgroundModel = self.gameController.backgroundModel
	local collectionModel = self.gameController.collectionModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("SelectView")
	self.view = view

	noteChartSetLibraryModel.cacheModel = cacheModel
	noteChartSetLibraryModel.collectionModel = collectionModel
	noteChartSetLibraryModel.searchModel = searchModel
	noteChartLibraryModel.cacheModel = cacheModel
	noteChartLibraryModel.searchModel = searchModel
	scoreLibraryModel.scoreModel = scoreModel
	selectModel.collectionModel = collectionModel
	selectModel.configModel = configModel
	selectModel.searchModel = searchModel
	selectModel.noteChartSetLibraryModel = noteChartSetLibraryModel
	selectModel.noteChartLibraryModel = noteChartLibraryModel
	selectModel.scoreLibraryModel = scoreLibraryModel
	previewModel.configModel = configModel
	previewModel.cacheModel = cacheModel
	searchModel.scoreModel = scoreModel

	view.themeModel = themeModel
	view.noteChartModel = noteChartModel
	view.modifierModel = modifierModel
	view.noteSkinModel = noteSkinModel
	view.inputModel = inputModel
	view.cacheModel = cacheModel
	view.configModel = configModel
	view.mountModel = mountModel
	view.scoreModel = scoreModel
	view.onlineModel = onlineModel
	view.backgroundModel = backgroundModel

	view.controller = self
	view.noteChartSetLibraryModel = noteChartSetLibraryModel
	view.noteChartLibraryModel = noteChartLibraryModel
	view.scoreLibraryModel = scoreLibraryModel
	view.searchModel = searchModel
	view.selectModel = selectModel

	noteChartModel:load()
	selectModel:load()
	previewModel:load()

	view:load()
end

SelectController.unload = function(self)
	self.previewModel:unload()
	self.view:unload()
end

SelectController.update = function(self, dt)
	self.previewModel:update(dt)
	self.selectModel:update()
	self.view:update(dt)
end

SelectController.draw = function(self)
	self.view:draw()
end

SelectController.receive = function(self, event)
	self.searchModel:receive(event)
	self.view:receive(event)

	if event.name == "setTheme" then
		self.themeModel:setDefaultTheme(event.theme)
	elseif event.name == "scrollNoteChartSet" then
		self.selectModel:scrollNoteChartSet(event.direction)
	elseif event.name == "scrollNoteChart" then
		self.selectModel:scrollNoteChart(event.direction)
	elseif event.name == "scrollScore" then
		self.selectModel:scrollScore(event.direction)
	elseif event.name == "changeScreen" then
		if event.screenName == "Modifier" then
			self:switchModifierController()
		elseif event.screenName == "NoteSkin" then
			self:switchNoteSkinController()
		elseif event.screenName == "Input" then
			self:switchInputController()
		elseif event.screenName == "Settings" then
			self:switchSettingsController()
		elseif event.screenName == "Collection" then
			self:switchCollectionController()
		end
	elseif event.name == "startCacheUpdate" then
		self.gameController.cacheModel:startUpdate()
		print("start update")
	elseif event.name == "stopCacheUpdate" then
		self.gameController.cacheModel:stopUpdate()
		print("stop update")
	elseif event.action == "playNoteChart" then
		self:playNoteChart()
	elseif event.name == "loadModifiedNoteChart" then
		self:loadModifiedNoteChart()
	elseif event.name == "unloadModifiedNoteChart" then
		self:unloadModifiedNoteChart()
	elseif event.name == "resetModifiedNoteChart" then
		self:resetModifiedNoteChart()
	elseif event.action == "replayNoteChart" then
		-- self:replayNoteChart(event.mode, event.scoreEntry.replayHash)
	elseif event.name == "quickLogin" then
		self.onlineModel:quickLogin(self.configModel:getConfig("settings").online.quick_login_key)
	end
end

SelectController.resetModifiedNoteChart = function(self)
	local noteChartModel = self.gameController.noteChartModel
	local modifierModel = self.gameController.modifierModel

	local noteChart = noteChartModel:loadNoteChart()

	if not noteChart then
		return
	end

	modifierModel.noteChart = noteChart
	modifierModel:apply("NoteChartModifier")
end

SelectController.loadModifiedNoteChart = function(self)
	if not self.noteChartModel.noteChart then
		self:resetModifiedNoteChart()
	end
end

SelectController.unloadModifiedNoteChart = function(self)
	self.noteChartModel:unloadNoteChart()
end

SelectController.switchModifierController = function(self)
	if not self.gameController.noteChartModel:getFileInfo() then
		return
	end

	local ModifierController = require("sphere.controllers.ModifierController")
	local modifierController = ModifierController:new()
	modifierController.selectController = self
	modifierController.gameController = self.gameController
	return self.gameController.screenManager:set(modifierController)
end

SelectController.switchNoteSkinController = function(self)
	if not self.gameController.noteChartModel:getFileInfo() then
		return
	end

	self:resetModifiedNoteChart()

	local NoteSkinController = require("sphere.controllers.NoteSkinController")
	local noteSkinController = NoteSkinController:new()
	noteSkinController.selectController = self
	noteSkinController.gameController = self.gameController
	return self.gameController.screenManager:set(noteSkinController)
end

SelectController.switchInputController = function(self)
	if not self.gameController.noteChartModel:getFileInfo() then
		return
	end

	self:resetModifiedNoteChart()

	local InputController = require("sphere.controllers.InputController")
	local inputController = InputController:new()
	inputController.selectController = self
	inputController.gameController = self.gameController
	return self.gameController.screenManager:set(inputController)
end

SelectController.switchSettingsController = function(self)
	local SettingsController = require("sphere.controllers.SettingsController")
	local settingsController = SettingsController:new()
	settingsController.selectController = self
	settingsController.gameController = self.gameController
	return self.gameController.screenManager:set(settingsController)
end

SelectController.switchCollectionController = function(self)
	local CollectionController = require("sphere.controllers.CollectionController")
	local collectionController = CollectionController:new()
	collectionController.selectController = self
	collectionController.gameController = self.gameController
	return self.gameController.screenManager:set(collectionController)
end

SelectController.playNoteChart = function(self)
	if not self.gameController.noteChartModel:getFileInfo() then
		return
	end

	local GameplayController = require("sphere.controllers.GameplayController")
	local gameplayController = GameplayController:new()
	gameplayController.selectController = self
	gameplayController.gameController = self.gameController
	return self.gameController.screenManager:set(gameplayController)
end

SelectController.replayNoteChart = function(self, mode, hash)
	local noteChartModel = self.noteChartModel
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

	local replay = gameplayController.rhythmModel.replayModel:loadReplay(hash)

	if replay.modifiers then
		self.modifierModel:fromTable(replay.modifiers)
	end
	if mode == "replay" or mode == "result" then
		gameplayController.rhythmModel.replayModel.replay = replay
		gameplayController.rhythmModel.inputManager:setMode("internal")
		gameplayController.rhythmModel.replayModel:setMode("replay")
	elseif mode == "retry" then
		gameplayController.rhythmModel.inputManager:setMode("external")
		gameplayController.rhythmModel.replayModel:setMode("record")
	end

	gameplayController.selectController = self
	gameplayController.gameController = self.gameController

	if mode == "result" then
		noteChartModel:unload()
		gameplayController:play()

		local ResultController = require("sphere.controllers.ResultController")
		local resultController = ResultController:new()

		resultController.selectController = self
		resultController.gameController = self.gameController

		self.gameController.screenManager:set(resultController)
	else
		return self.gameController.screenManager:set(gameplayController)
	end
end

return SelectController
