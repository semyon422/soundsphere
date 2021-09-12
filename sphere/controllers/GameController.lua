local aquaevent					= require("aqua.event")
local Class						= require("aqua.util.Class")
local ThreadPool				= require("aqua.thread.ThreadPool")
local ConfigModel				= require("sphere.models.ConfigModel")
local ScoreModel				= require("sphere.models.ScoreModel")
local DiscordPresence			= require("sphere.discord.DiscordPresence")
local MountModel				= require("sphere.models.MountModel")
local MountController			= require("sphere.controllers.MountController")
local OnlineController			= require("sphere.controllers.OnlineController")
local ScreenManager				= require("sphere.screen.ScreenManager")
local FadeTransition			= require("sphere.screen.FadeTransition")
local SelectController			= require("sphere.controllers.SelectController")
local WindowManager				= require("sphere.window.WindowManager")
local FpsLimiter				= require("sphere.window.FpsLimiter")
local Screenshot				= require("sphere.window.Screenshot")
local DirectoryManager			= require("sphere.filesystem.DirectoryManager")
local NotificationView			= require("sphere.views.NotificationView")
local NotificationModel			= require("sphere.models.NotificationModel")
local ThemeModel				= require("sphere.models.ThemeModel")
local OnlineModel				= require("sphere.models.OnlineModel")
local CacheModel				= require("sphere.models.CacheModel")
local BackgroundModel			= require("sphere.models.BackgroundModel")
local NoteChartModel		= require("sphere.models.NoteChartModel")
local ModifierModel			= require("sphere.models.ModifierModel")
local NoteSkinModel			= require("sphere.models.NoteSkinModel")
local InputModel			= require("sphere.models.InputModel")
local CacheModel			= require("sphere.models.CacheModel")
local DifficultyModel		= require("sphere.models.DifficultyModel")
local CollectionModel		= require("sphere.models.CollectionModel")
local SettingsModel		= require("sphere.models.SettingsModel")
local NoteChartSetLibraryModel		= require("sphere.models.NoteChartSetLibraryModel")
local NoteChartLibraryModel		= require("sphere.models.NoteChartLibraryModel")
local ScoreLibraryModel		= require("sphere.models.ScoreLibraryModel")
local SortModel		= require("sphere.models.SortModel")
local SearchModel		= require("sphere.models.SearchModel")
local SelectModel		= require("sphere.models.SelectModel")
local PreviewModel		= require("sphere.models.PreviewModel")
local UpdateModel		= require("sphere.models.UpdateModel")
local MainLog					= require("sphere.MainLog")

local GameController = Class:new()

GameController.construct = function(self)
	self.configModel = ConfigModel:new()
	self.notificationModel = NotificationModel:new()
	self.notificationView = NotificationView:new()
	self.windowManager = WindowManager:new()
	self.mountModel = MountModel:new()
	self.mountController = MountController:new()
	self.onlineController = OnlineController:new()
	self.screenshot = Screenshot:new()
	self.directoryManager = DirectoryManager:new()
	self.themeModel = ThemeModel:new()
	self.scoreModel = ScoreModel:new()
	self.onlineModel = OnlineModel:new()
	self.cacheModel = CacheModel:new()
	self.backgroundModel = BackgroundModel:new()
	self.fadeTransition = FadeTransition:new()
	self.screenManager = ScreenManager:new()
	self.modifierModel = ModifierModel:new()
	self.noteSkinModel = NoteSkinModel:new()
	self.noteChartModel = NoteChartModel:new()
	self.inputModel = InputModel:new()
	self.difficultyModel = DifficultyModel:new()
	self.collectionModel = CollectionModel:new()
	self.settingsModel = SettingsModel:new()
	self.noteChartSetLibraryModel = NoteChartSetLibraryModel:new()
	self.noteChartLibraryModel = NoteChartLibraryModel:new()
	self.scoreLibraryModel = ScoreLibraryModel:new()
	self.sortModel = SortModel:new()
	self.searchModel = SearchModel:new()
	self.selectModel = SelectModel:new()
	self.previewModel = PreviewModel:new()
	self.updateModel = UpdateModel:new()
	self.fpsLimiter = FpsLimiter:new()
end

GameController.load = function(self)
	local notificationModel = self.notificationModel
	local notificationView = self.notificationView
	local configModel = self.configModel
	local windowManager = self.windowManager
	local mountModel = self.mountModel
	local mountController = self.mountController
	local onlineController = self.onlineController
	local screenshot = self.screenshot
	local directoryManager = self.directoryManager
	local themeModel = self.themeModel
	local scoreModel = self.scoreModel
	local onlineModel = self.onlineModel
	local cacheModel = self.cacheModel
	local backgroundModel = self.backgroundModel
	local modifierModel = self.modifierModel
	local noteSkinModel = self.noteSkinModel
	local noteChartModel = self.noteChartModel
	local inputModel = self.inputModel
	local difficultyModel = self.difficultyModel
	local collectionModel = self.collectionModel
	local settingsModel = self.settingsModel
	local selectModel = self.selectModel
	local updateModel = self.updateModel
	local fpsLimiter = self.fpsLimiter

	directoryManager:createDirectories()

	MainLog:write("trace", "starting game")

	configModel:addConfig("settings_model", "userdata/settings_model.json", "sphere/models/ConfigModel/settings_model.json", "json")
	configModel:addConfig("settings", "userdata/settings.toml", "sphere/models/ConfigModel/settings.toml", "toml")
	configModel:addConfig("select", "userdata/select.toml", "sphere/models/ConfigModel/select.toml", "toml")
	configModel:addConfig("modifier", "userdata/modifier.json", "sphere/models/ConfigModel/modifier.json", "json")
	configModel:addConfig("noteskin", "userdata/noteskin.toml", "sphere/models/ConfigModel/noteskin.toml", "toml")
	configModel:addConfig("input", "userdata/input.json", "sphere/models/ConfigModel/input.json", "json")
	configModel:addConfig("mount", "userdata/mount.json", "sphere/models/ConfigModel/mount.json", "json")
	configModel:addConfig("window", "userdata/window.json", "sphere/models/ConfigModel/window.json", "json")
	configModel:addConfig("result", "userdata/result.json", "sphere/models/ConfigModel/result.json", "json")
	configModel:addConfig("online", "userdata/online.toml", "sphere/models/ConfigModel/online.toml", "toml")

	configModel:readConfig("settings_model")
	configModel:readConfig("settings")
	configModel:readConfig("select")
	configModel:readConfig("modifier")
	configModel:readConfig("noteskin")
	configModel:readConfig("input")
	configModel:readConfig("mount")
	configModel:readConfig("window")
	configModel:readConfig("result")
	configModel:readConfig("online")

	onlineController.onlineModel = onlineModel
	onlineController.cacheModel = cacheModel
	onlineController.configModel = configModel

	noteChartModel.cacheModel = cacheModel
	noteChartModel.configModel = configModel
	noteChartModel.scoreModel = scoreModel
	noteSkinModel.configModel = configModel
	modifierModel.noteChartModel = noteChartModel
	modifierModel.difficultyModel = difficultyModel
	modifierModel.scoreModel = scoreModel
	modifierModel.configModel = configModel
	inputModel.configModel = configModel

	settingsModel.configModel = configModel
	settingsModel:load()

	themeModel.configModel = configModel
	themeModel:load()

	selectModel.collectionModel = collectionModel

	modifierModel:load()

	mountModel.configModel = configModel

	mountController.mountModel = mountModel
	mountModel:load()

	notificationModel.observable:add(notificationView)
	notificationView:load()

	updateModel.configModel = configModel
	updateModel:load()

	windowManager.configModel = configModel
	windowManager:load()

	screenshot.configModel = configModel
	fpsLimiter.configModel = configModel

	scoreModel:select()
	-- configModel:read()

	onlineModel.configModel = configModel
	onlineModel.observable:add(onlineController)
	onlineModel:load()

	inputModel:load()
	noteSkinModel:load()
	cacheModel:load()
	noteChartModel:load()

	onlineController:load()

	DiscordPresence:load()

	backgroundModel.configModel = configModel
	backgroundModel.cacheModel = cacheModel
	backgroundModel:load()

	collectionModel.configModel = configModel
	collectionModel.cacheModel = self.cacheModel
	collectionModel:load()

	self.screenManager:setTransition(self.fadeTransition)

	local selectController = SelectController:new()
	self.selectController = selectController

	selectController.gameController = self

	self.screenManager:set(selectController)
end

GameController.unload = function(self)
	self.screenManager:unload()
	DiscordPresence:unload()
	self.backgroundModel:unload()
	self.configModel:writeConfig("settings")
	self.configModel:writeConfig("select")
	self.configModel:writeConfig("modifier")
	self.configModel:writeConfig("noteskin")
	self.configModel:writeConfig("input")
	self.configModel:writeConfig("mount")
	self.configModel:writeConfig("window")
	self.configModel:writeConfig("online")
	self.mountModel:unload()
	self.onlineModel:unload()
end

GameController.update = function(self, dt)
	ThreadPool:update()

	DiscordPresence:update()
	self.backgroundModel:update(dt)
	self.screenManager:update(dt)
	self.notificationView:update(dt)
	self.onlineController:update()
	self.fpsLimiter:update()
end

GameController.draw = function(self)
	self.screenManager:draw()
	self.notificationView:draw()
end

GameController.receive = function(self, event)
	if event.name == "update" then
		return self:update(event.args[1])
	elseif event.name == "draw" then
		return self:draw()
	elseif event.name == "quit" then
		self:unload()
		aquaevent.quit()
		return
	end

	self.screenManager:receive(event)
	self.windowManager:receive(event)
	self.screenshot:receive(event)
	self.mountController:receive(event)
	self.notificationView:receive(event)
end

return GameController
