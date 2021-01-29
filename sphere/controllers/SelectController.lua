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

	modifierModel.config = configModel:getConfig("modifier")

	inputModel:load()
	-- modifierModel:load()
	noteSkinModel:load()
	cacheModel:load()
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

    if event.name == "setNoteSkin" then
		self.noteSkinModel:setDefaultNoteSkin(event.inputMode, event.metaData)
	elseif event.name == "setTheme" then
		self.themeModel:setDefaultTheme(event.theme)
	elseif event.name == "setInputBinding" then
		self.inputModel:setKey(event.inputMode, event.virtualKey, event.value, event.type)
	elseif event.name == "selectSearchString" then
		config.searchString = event.searchString
	elseif event.name == "selectNoteChartSetEntry" then
		config.noteChartSetEntryId = event.noteChartSetEntryId
		self.noteChartModel:select()
	elseif event.name == "selectNoteChartEntry" then
		config.noteChartEntryId = event.noteChartEntryId
		self.noteChartModel:select()
	elseif event.name == "selectNoteChartDataEntry" then
		config.noteChartDataEntryId = event.noteChartDataEntryId
		self.noteChartModel:select()
	elseif event.name == "selectScoreEntry" then
		config.scoreEntryId = event.scoreEntryId
		self.noteChartModel:select()
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

SelectController.playNoteChart = function(self)
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

	-- local GameplayController = require("sphere.controllers.GameplayController")
	-- local gameplayController = GameplayController:new()
	-- gameplayController.noteChartModel = noteChartModel
	-- gameplayController.themeModel = self.themeModel
	-- gameplayController.modifierModel = self.modifierModel
	-- gameplayController.configModel = self.configModel
	-- gameplayController.notificationModel = self.notificationModel
	-- gameplayController.scoreModel = self.scoreModel
	-- gameplayController.onlineModel = self.onlineModel
	-- gameplayController.difficultyModel = self.difficultyModel
	-- gameplayController.selectController = self
	-- return ScreenManager:set(gameplayController)
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
