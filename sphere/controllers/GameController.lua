local aquaevent					= require("aqua.event")
local Class						= require("aqua.util.Class")
local ConfigModel				= require("sphere.models.ConfigModel")
local ScoreModel				= require("sphere.models.ScoreModel")
local DiscordModel				= require("sphere.models.DiscordModel")
local MountModel				= require("sphere.models.MountModel")
local MountController			= require("sphere.controllers.MountController")
local OnlineController			= require("sphere.controllers.OnlineController")
local ScreenManager				= require("sphere.screen.ScreenManager")
local FadeTransition			= require("sphere.screen.FadeTransition")
local SelectController			= require("sphere.controllers.SelectController")
local ErrorController			= require("sphere.controllers.ErrorController")
local WindowManager				= require("sphere.window.WindowManager")
local FpsLimiter				= require("sphere.window.FpsLimiter")
local Screenshot				= require("sphere.window.Screenshot")
local DirectoryManager			= require("sphere.filesystem.DirectoryManager")
local NotificationModel			= require("sphere.models.NotificationModel")
local ThemeModel				= require("sphere.models.ThemeModel")
local OnlineModel				= require("sphere.models.OnlineModel")
local BackgroundModel			= require("sphere.models.BackgroundModel")
local NoteChartModel		= require("sphere.models.NoteChartModel")
local ModifierModel			= require("sphere.models.ModifierModel")
local NoteSkinModel			= require("sphere.models.NoteSkinModel")
local InputModel			= require("sphere.models.InputModel")
local CacheModel			= require("sphere.models.CacheModel")
local DifficultyModel		= require("sphere.models.DifficultyModel")
local CollectionModel		= require("sphere.models.CollectionModel")
local NoteChartSetLibraryModel		= require("sphere.models.NoteChartSetLibraryModel")
local NoteChartLibraryModel		= require("sphere.models.NoteChartLibraryModel")
local ScoreLibraryModel		= require("sphere.models.ScoreLibraryModel")
local SortModel		= require("sphere.models.SortModel")
local SearchModel		= require("sphere.models.SearchModel")
local SelectModel		= require("sphere.models.SelectModel")
local PreviewModel		= require("sphere.models.PreviewModel")
local UpdateModel		= require("sphere.models.UpdateModel")
local RhythmModel		= require("sphere.models.RhythmModel")
local OsudirectModel		= require("sphere.models.OsudirectModel")
local MainLog					= require("sphere.MainLog")
local FrameTimeView					= require("sphere.views.FrameTimeView")

local GameController = Class:new()

GameController.baseVsync = 1

GameController.construct = function(self)
	self.configModel = ConfigModel:new()
	self.notificationModel = NotificationModel:new()
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
	self.noteChartSetLibraryModel = NoteChartSetLibraryModel:new()
	self.noteChartLibraryModel = NoteChartLibraryModel:new()
	self.scoreLibraryModel = ScoreLibraryModel:new()
	self.sortModel = SortModel:new()
	self.searchModel = SearchModel:new()
	self.selectModel = SelectModel:new()
	self.previewModel = PreviewModel:new()
	self.updateModel = UpdateModel:new()
	self.fpsLimiter = FpsLimiter:new()
	self.rhythmModel = RhythmModel:new()
	self.discordModel = DiscordModel:new()
	self.osudirectModel = OsudirectModel:new()
	self.frameTimeView = FrameTimeView:new()
end

GameController.load = function(self)
	local notificationModel = self.notificationModel
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
	local selectModel = self.selectModel
	local updateModel = self.updateModel
	local fpsLimiter = self.fpsLimiter
	local rhythmModel = self.rhythmModel
	local noteChartSetLibraryModel = self.noteChartSetLibraryModel
	local noteChartLibraryModel = self.noteChartLibraryModel
	local searchModel = self.searchModel
	local scoreLibraryModel = self.scoreLibraryModel
	local sortModel = self.sortModel
	local previewModel = self.previewModel
	local discordModel = self.discordModel
	local osudirectModel = self.osudirectModel

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
	modifierModel.rhythmModel = rhythmModel
	inputModel.configModel = configModel
	rhythmModel.modifierModel = modifierModel
	rhythmModel.configModel = configModel
	noteChartSetLibraryModel.cacheModel = cacheModel
	noteChartSetLibraryModel.collectionModel = collectionModel
	noteChartSetLibraryModel.searchModel = searchModel
	noteChartSetLibraryModel.selectModel = selectModel
	noteChartSetLibraryModel.sortModel = sortModel
	noteChartLibraryModel.cacheModel = cacheModel
	noteChartLibraryModel.searchModel = searchModel
	noteChartLibraryModel.selectModel = selectModel
	scoreLibraryModel.scoreModel = scoreModel
	selectModel.cacheModel = cacheModel
	selectModel.collectionModel = collectionModel
	selectModel.configModel = configModel
	selectModel.searchModel = searchModel
	selectModel.noteChartSetLibraryModel = noteChartSetLibraryModel
	selectModel.noteChartLibraryModel = noteChartLibraryModel
	selectModel.osudirectModel = osudirectModel
	selectModel.sortModel = sortModel
	selectModel.scoreLibraryModel = scoreLibraryModel
	selectModel.collectionModel = collectionModel
	previewModel.configModel = configModel
	previewModel.selectModel = selectModel
	previewModel.rhythmModel = rhythmModel
	searchModel.scoreModel = scoreModel
	searchModel.configModel = configModel
	themeModel.configModel = configModel
	mountModel.configModel = configModel
	mountController.mountModel = mountModel
	updateModel.configModel = configModel
	windowManager.configModel = configModel
	screenshot.configModel = configModel
	fpsLimiter.configModel = configModel
	onlineModel.configModel = configModel
	backgroundModel.configModel = configModel
	backgroundModel.selectModel = selectModel
	collectionModel.configModel = configModel
	collectionModel.cacheModel = cacheModel
	scoreModel.configModel = configModel
	osudirectModel.configModel = configModel

	directoryManager:createDirectories()

	MainLog:write("trace", "starting game")

	configModel:readConfig("settings_model", "userdata/settings_model.lua", "sphere/models/ConfigModel/settings_model.lua")
	configModel:readConfig("settings", "userdata/settings.lua", "sphere/models/ConfigModel/settings.lua")
	configModel:readConfig("select", "userdata/select.lua", "sphere/models/ConfigModel/select.lua")
	configModel:readConfig("modifier", "userdata/modifier.lua", "sphere/models/ConfigModel/modifier.lua")
	configModel:readConfig("input", "userdata/input.lua", "sphere/models/ConfigModel/input.lua")
	configModel:readConfig("mount", "userdata/mount.lua", "sphere/models/ConfigModel/mount.lua")
	configModel:readConfig("online", "userdata/online.lua", "sphere/models/ConfigModel/online.lua")
	configModel:readConfig("urls", "userdata/urls.lua", "sphere/models/ConfigModel/urls.lua")
	configModel:readConfig("judgements", "userdata/judgements.lua", "sphere/models/ConfigModel/judgements.lua")
	configModel:readConfig("files", "userdata/files.lua", "sphere/models/ConfigModel/files.lua")

	rhythmModel.timings = configModel.configs.settings.gameplay.timings
	rhythmModel.judgements = configModel.configs.judgements
	rhythmModel.hp = configModel.configs.settings.gameplay.hp
	rhythmModel.settings = configModel.configs.settings

	themeModel:load()
	modifierModel:load()
	mountModel:load()
	updateModel:load()
	windowManager:load()
	scoreModel:load()
	onlineModel:load()
	inputModel:load()
	noteSkinModel:load()
	cacheModel:load()
	noteChartModel:load()
	noteChartSetLibraryModel:load()
	noteChartLibraryModel:load()
	osudirectModel:load()
	onlineController:load()
	discordModel:load()
	backgroundModel:load()
	collectionModel:load()
	selectModel:load()
	previewModel:load()
	self.frameTimeView:load()

	self.screenManager:setTransition(self.fadeTransition)

	local errorController = ErrorController:new()
	self.errorController = errorController
	errorController.gameController = self
	self.screenManager:setFallback(errorController)

	local selectController = SelectController:new()
	self.selectController = selectController
	selectController.gameController = self
	self.screenManager:set(selectController)
end

GameController.resetGameplayConfigs = function(self)
	self.modifierModel.config = self.configModel.configs.modifier
	self.rhythmModel.timings = self.configModel.configs.timings
end

GameController.writeConfigs = function(self)
	self.configModel:writeConfig("settings")
	self.configModel:writeConfig("select")
	self.configModel:writeConfig("modifier")
	self.configModel:writeConfig("input")
	self.configModel:writeConfig("mount")
	self.configModel:writeConfig("online")
end

GameController.unload = function(self)
	self.screenManager:unload()
	self.discordModel:unload()
	self.mountModel:unload()
	self.onlineModel:unload()
	self:writeConfigs()
end

GameController.update = function(self, dt)
	local startTime = love.timer.getTime()

	self.discordModel:update()
	self.notificationModel:update()
	self.backgroundModel:update(dt)
	self.screenManager:update(dt)
	self.onlineController:update()
	self.fpsLimiter:update()
	self.windowManager:update()

	self.cacheModel:update()
	-- self.noteChartSetLibraryModel:update()
	-- self.noteChartLibraryModel:update()

	self.frameTimeView.updateFrameTime = love.timer.getTime() - startTime
end

GameController.draw = function(self)
	local startTime = love.timer.getTime()

	self.screenManager:draw()

	love.graphics.origin()
	self.frameTimeView:draw()

	self.frameTimeView.drawFrameTime = love.timer.getTime() - startTime
end

GameController.receive = function(self, event)
	local startTime = love.timer.getTime()

	if event.name == "update" then
		return self:update(event[1])
	elseif event.name == "draw" then
		return self:draw()
	elseif event.name == "resize" then
		self.frameTimeView:load()
	elseif event.name == "quit" then
		return self:unload()
	end

	self.screenManager:receive(event)
	self.windowManager:receive(event)
	self.screenshot:receive(event)
	self.mountController:receive(event)
	self.frameTimeView:receive(event)

	self.frameTimeView.receiveFrameTime = love.timer.getTime() - startTime
end

return GameController
