local Class					= require("aqua.util.Class")
local ScreenManager			= require("sphere.screen.ScreenManager")
local NoteChartModel		= require("sphere.models.NoteChartModel")
local ModifierModel			= require("sphere.models.ModifierModel")
local NoteSkinModel			= require("sphere.models.NoteSkinModel")
local InputModel			= require("sphere.models.InputModel")
local CacheModel			= require("sphere.models.CacheModel")
local ModifierController	= require("sphere.controllers.ModifierController")
local DifficultyModel		= require("sphere.models.DifficultyModel")
local NoteChartSetLibraryModel		= require("sphere.models.NoteChartSetLibraryModel")
local NoteChartLibraryModel		= require("sphere.models.NoteChartLibraryModel")
local ScoreLibraryModel		= require("sphere.models.ScoreLibraryModel")
local SearchLineModel		= require("sphere.models.SearchLineModel")
local SelectModel		= require("sphere.models.SelectModel")

local SelectController = Class:new()

SelectController.construct = function(self)
	self.modifierModel = ModifierModel:new()
	self.noteSkinModel = NoteSkinModel:new()
	self.noteChartModel = NoteChartModel:new()
	self.inputModel = InputModel:new()
	self.difficultyModel = DifficultyModel:new()
	self.noteChartSetLibraryModel = NoteChartSetLibraryModel:new()
	self.noteChartLibraryModel = NoteChartLibraryModel:new()
	self.scoreLibraryModel = ScoreLibraryModel:new()
	self.searchLineModel = SearchLineModel:new()
	self.selectModel = SelectModel:new()
end

SelectController.load = function(self)
	local modifierModel = self.modifierModel
	local noteSkinModel = self.noteSkinModel
	local noteChartModel = self.noteChartModel
	local inputModel = self.inputModel
	local cacheModel = self.cacheModel
	local themeModel = self.themeModel
	local configModel = self.configModel
	local mountModel = self.mountModel
	local scoreModel = self.scoreModel
	local onlineModel = self.onlineModel
	local difficultyModel = self.difficultyModel
	local noteChartSetLibraryModel = self.noteChartSetLibraryModel
	local noteChartLibraryModel = self.noteChartLibraryModel
	local scoreLibraryModel = self.scoreLibraryModel
	local searchLineModel = self.searchLineModel
	local backgroundModel = self.backgroundModel
	local selectModel = self.selectModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("SelectView")
	self.view = view

	noteChartModel.cacheModel = cacheModel
	noteChartModel.configModel = configModel
	noteChartModel.scoreModel = scoreModel
	noteSkinModel.configModel = configModel
	modifierModel.noteChartModel = noteChartModel
	modifierModel.difficultyModel = difficultyModel
	modifierModel.scoreModel = scoreModel
	noteChartSetLibraryModel.cacheModel = cacheModel
	noteChartLibraryModel.cacheModel = cacheModel
	scoreLibraryModel.scoreModel = scoreModel
	inputModel.configModel = configModel
	backgroundModel.configModel = configModel

	selectModel.noteChartModel = noteChartModel
	selectModel.configModel = configModel
	selectModel.searchLineModel = searchLineModel
	selectModel.noteChartSetLibraryModel = noteChartSetLibraryModel
	selectModel.noteChartLibraryModel = noteChartLibraryModel
	selectModel.scoreLibraryModel = scoreLibraryModel

	view.controller = self
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
	view.noteChartSetLibraryModel = noteChartSetLibraryModel
	view.noteChartLibraryModel = noteChartLibraryModel
	view.scoreLibraryModel = scoreLibraryModel
	view.searchLineModel = searchLineModel
	view.backgroundModel = backgroundModel
	view.selectModel = selectModel

	modifierModel.config = configModel:getConfig("modifier")

	inputModel:load()
	-- modifierModel:load()
	noteSkinModel:load()
	cacheModel:load()

	selectModel:load()

	noteChartModel:select()

	view:load()
end

SelectController.unload = function(self)
	-- self.modifierModel:unload()
	self.view:unload()
	self.inputModel:unload()
end

SelectController.update = function(self, dt)
	self.view:update(dt)
end

SelectController.draw = function(self)
	self.view:draw()
end

SelectController.receive = function(self, event)
	local config = self.configModel:getConfig("select")

	self.view:receive(event)

	if event.name == "setTheme" then
		self.themeModel:setDefaultTheme(event.theme)
	elseif event.name == "updateSearch" then
		self.selectModel:updateSearch()
	elseif event.name == "scrollNoteChartSet" then 
		self.selectModel:scrollNoteChartSet(event.direction)
	elseif event.name == "scrollNoteChart" then 
		self.selectModel:scrollNoteChart(event.direction)
	elseif event.name == "scrollScore" then 
		self.selectModel:scrollScore(event.direction)
	elseif event.action == "clickSelectMenu" then
		if event.item.controllerName == "ModifierController" then
			self:switchModifierController()
		elseif event.item.controllerName == "NoteSkinController" then
			self:switchNoteSkinController()
		elseif event.item.controllerName == "InputController" then
			self:switchInputController()
		elseif event.item.controllerName == "SettingsController" then
			self:switchSettingsController()
		end
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
	elseif event.name == "setScreen" then
		if event.screenName == "BrowserScreen" then
			local BrowserController = require("sphere.controllers.BrowserController")
			local browserController = BrowserController:new()
			browserController.configModel = self.configModel
			browserController.cacheModel = self.cacheModel
			browserController.themeModel = self.themeModel
			browserController.selectController = self
			return ScreenManager:set(browserController)
		elseif event.screenName == "SettingsScreen" then
			local SettingsController = require("sphere.controllers.SettingsController")
			local settingsController = SettingsController:new()
			settingsController.configModel = self.configModel
			settingsController.themeModel = self.themeModel
			settingsController.selectController = self
			return ScreenManager:set(settingsController)
		end
	end
end

SelectController.resetModifiedNoteChart = function(self)
	local noteChartModel = self.noteChartModel
	local modifierModel = self.modifierModel

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
	local noteChartModel = self.noteChartModel
	local info = love.filesystem.getInfo(noteChartModel.noteChartEntry.path)
	if not info then
		return
	end

	local ModifierController = require("sphere.controllers.ModifierController")
	local modifierController = ModifierController:new()
	modifierController.noteChartModel = noteChartModel
	modifierController.themeModel = self.themeModel
	modifierController.modifierModel = self.modifierModel
	modifierController.configModel = self.configModel
	modifierController.notificationModel = self.notificationModel
	modifierController.scoreModel = self.scoreModel
	modifierController.onlineModel = self.onlineModel
	modifierController.difficultyModel = self.difficultyModel
	modifierController.selectController = self
	return ScreenManager:set(modifierController)
end

SelectController.switchNoteSkinController = function(self)
	local noteChartModel = self.noteChartModel
	local info = love.filesystem.getInfo(noteChartModel.noteChartEntry.path)
	if not info then
		return
	end

	self:resetModifiedNoteChart()

	local NoteSkinController = require("sphere.controllers.NoteSkinController")
	local noteSkinController = NoteSkinController:new()
	noteSkinController.noteChartModel = noteChartModel
	noteSkinController.noteSkinModel = self.noteSkinModel
	noteSkinController.themeModel = self.themeModel
	noteSkinController.modifierModel = self.modifierModel
	noteSkinController.configModel = self.configModel
	noteSkinController.notificationModel = self.notificationModel
	noteSkinController.scoreModel = self.scoreModel
	noteSkinController.onlineModel = self.onlineModel
	noteSkinController.difficultyModel = self.difficultyModel
	noteSkinController.selectController = self
	return ScreenManager:set(noteSkinController)
end

SelectController.switchInputController = function(self)
	local noteChartModel = self.noteChartModel
	local info = love.filesystem.getInfo(noteChartModel.noteChartEntry.path)
	if not info then
		return
	end

	self:resetModifiedNoteChart()

	local InputController = require("sphere.controllers.InputController")
	local inputController = InputController:new()
	inputController.noteChartModel = noteChartModel
	inputController.noteSkinModel = self.noteSkinModel
	inputController.themeModel = self.themeModel
	inputController.modifierModel = self.modifierModel
	inputController.configModel = self.configModel
	inputController.notificationModel = self.notificationModel
	inputController.scoreModel = self.scoreModel
	inputController.onlineModel = self.onlineModel
	inputController.difficultyModel = self.difficultyModel
	inputController.inputModel = self.inputModel
	inputController.selectController = self
	return ScreenManager:set(inputController)
end

SelectController.switchSettingsController = function(self)
	local SettingsController = require("sphere.controllers.SettingsController")
	local settingsController = SettingsController:new()
	settingsController.noteChartModel = self.noteChartModel
	settingsController.noteSkinModel = self.noteSkinModel
	settingsController.themeModel = self.themeModel
	settingsController.modifierModel = self.modifierModel
	settingsController.configModel = self.configModel
	settingsController.notificationModel = self.notificationModel
	settingsController.scoreModel = self.scoreModel
	settingsController.onlineModel = self.onlineModel
	settingsController.difficultyModel = self.difficultyModel
	settingsController.inputModel = self.inputModel
	settingsController.selectController = self
	return ScreenManager:set(settingsController)
end

SelectController.playNoteChart = function(self)
	local noteChartModel = self.noteChartModel
	local info = love.filesystem.getInfo(noteChartModel.noteChartEntry.path)
	if not info then
		return
	end

	local GameplayController = require("sphere.controllers.GameplayController")
	local gameplayController = GameplayController:new()
	gameplayController.noteChartModel = noteChartModel
	gameplayController.inputModel = self.inputModel
	gameplayController.themeModel = self.themeModel
	gameplayController.modifierModel = self.modifierModel
	gameplayController.configModel = self.configModel
	gameplayController.notificationModel = self.notificationModel
	gameplayController.scoreModel = self.scoreModel
	gameplayController.onlineModel = self.onlineModel
	gameplayController.difficultyModel = self.difficultyModel
	gameplayController.selectController = self
	return ScreenManager:set(gameplayController)
end

SelectController.replayNoteChart = function(self, mode, hash)
	local noteChartModel = self.noteChartModel
	local info = love.filesystem.getInfo(noteChartModel.noteChartEntry.path)
	if not info then
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

	gameplayController.noteChartModel = noteChartModel
	gameplayController.modifierModel = self.modifierModel
	gameplayController.configModel = self.configModel
	gameplayController.notificationModel = self.notificationModel
	gameplayController.themeModel = self.themeModel
	gameplayController.scoreModel = self.scoreModel
	gameplayController.onlineModel = self.onlineModel
	gameplayController.difficultyModel = self.difficultyModel
	gameplayController.selectController = self

	if mode == "result" then
		noteChartModel:unload()
		gameplayController:play()

		local ResultController = require("sphere.controllers.ResultController")
		local resultController = ResultController:new()

		resultController.scoreSystem = gameplayController.rhythmModel.scoreEngine.scoreSystem
		resultController.noteChartModel = noteChartModel
		resultController.themeModel = self.themeModel
		resultController.modifierModel = self.modifierModel
		resultController.configModel = self.configModel
		resultController.scoreModel = self.scoreModel
		resultController.onlineModel = self.onlineModel
		resultController.difficultyModel = self.difficultyModel
		resultController.autoplay = gameplayController.rhythmModel.logicEngine.autoplay
		resultController.selectController = self

		ScreenManager:set(resultController)
	else
		return ScreenManager:set(gameplayController)
	end
end

return SelectController
