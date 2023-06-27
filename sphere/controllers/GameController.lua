local Class						= require("Class")
local ConfigModel				= require("sphere.models.ConfigModel")
local ScoreModel				= require("sphere.models.ScoreModel")
local DiscordModel				= require("sphere.models.DiscordModel")
local MountModel				= require("sphere.models.MountModel")
local WindowModel				= require("sphere.models.WindowModel")
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
local MultiplayerModel		= require("sphere.models.MultiplayerModel")
local ReplayModel		= require("sphere.models.ReplayModel")
local EditorModel		= require("sphere.models.EditorModel")
local SpeedModel		= require("sphere.models.SpeedModel")
local ScreenshotModel		= require("sphere.models.ScreenshotModel")
local AudioModel		= require("sphere.models.AudioModel")
local ResourceModel		= require("sphere.models.ResourceModel")

local MountController			= require("sphere.controllers.MountController")
local SelectController			= require("sphere.controllers.SelectController")
local GameplayController		= require("sphere.controllers.GameplayController")
local FastplayController		= require("sphere.controllers.FastplayController")
local ResultController			= require("sphere.controllers.ResultController")
local TimeController			= require("sphere.controllers.TimeController")
local MultiplayerController			= require("sphere.controllers.MultiplayerController")
local EditorController			= require("sphere.controllers.EditorController")

local GameView = require("sphere.views.GameView")
local SelectView = require("sphere.views.SelectView")
local ResultView = require("sphere.views.ResultView")
local GameplayView = require("sphere.views.GameplayView")
local MultiplayerView = require("sphere.views.MultiplayerView")
local EditorView = require("sphere.views.EditorView")

local GameController = Class:new()

local injects = {}
local function dinject(t, k, v)
	local T = getmetatable(t).__index
	local V = getmetatable(v).__index

	local Tn, Vn
	for mod, M in pairs(package.loaded) do
		if M == T then
			Tn = mod
		elseif M == V then
			Vn = mod
		end
	end

	table.insert(injects, {Tn, Vn})

	print(Tn, Vn)

	t[k] = v
end

local deps = {
	editorController = {
		"noteChartModel",
		"editorModel",
		"noteSkinModel",
		"previewModel",
		"configModel",
		"resourceModel",
		"windowModel",
	},
	fastplayController = {
		"rhythmModel",
		"replayModel",
		"modifierModel",
		"noteChartModel",
		"difficultyModel",
	},
	gameplayController = {
		"rhythmModel",
		"noteChartModel",
		"noteSkinModel",
		"configModel",
		"modifierModel",
		"difficultyModel",
		"replayModel",
		"timeController",
		"multiplayerModel",
		"previewModel",
		"discordModel",
		"scoreModel",
		"onlineModel",
		"selectModel",
		"resourceModel",
		"windowModel",
	},
	mountController = {
		"mountModel",
		"configModel",
		"cacheModel",
	},
	multiplayerController = {
		"multiplayerModel",
		"modifierModel",
		"configModel",
		"selectModel",
		"noteChartSetLibraryModel",
	},
	resultController = {
		"selectModel",
		"replayModel",
		"rhythmModel",
		"modifierModel",
		"onlineModel",
		"configModel",
		"fastplayController",
	},
	selectController = {
		"noteChartModel",
		"selectModel",
		"previewModel",
		"modifierModel",
		"noteSkinModel",
		"configModel",
		"backgroundModel",
		"multiplayerModel",
		"onlineModel",
		"mountModel",
		"cacheModel",
		"osudirectModel",
		"windowModel",
	},
	timeController = {
		"rhythmModel",
		"noteChartModel",
		"configModel",
		"multiplayerModel",
		"notificationModel",
		"speedModel",
	},
}

GameController.construct = function(self)
	self.mountController = MountController:new()
	self.selectController = SelectController:new()
	self.gameplayController = GameplayController:new()
	self.fastplayController = FastplayController:new()
	self.resultController = ResultController:new()
	self.timeController = TimeController:new()
	self.multiplayerController = MultiplayerController:new()
	self.editorController = EditorController:new()

	self.gameView = GameView:new()
	self.selectView = SelectView:new()
	self.resultView = ResultView:new()
	self.gameplayView = GameplayView:new()
	self.multiplayerView = MultiplayerView:new()
	self.editorView = EditorView:new()

	self.configModel = ConfigModel:new()
	self.notificationModel = NotificationModel:new()
	self.windowModel = WindowModel:new()
	self.mountModel = MountModel:new()
	self.screenshotModel = ScreenshotModel:new()
	self.directoryManager = DirectoryManager:new()
	self.themeModel = ThemeModel:new()
	self.scoreModel = ScoreModel:new()
	self.onlineModel = OnlineModel:new()
	self.cacheModel = CacheModel:new()
	self.backgroundModel = BackgroundModel:new()
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
	self.rhythmModel = RhythmModel:new()
	self.discordModel = DiscordModel:new()
	self.osudirectModel = OsudirectModel:new()
	self.multiplayerModel = MultiplayerModel:new()
	self.replayModel = ReplayModel:new()
	self.editorModel = EditorModel:new()
	self.speedModel = SpeedModel:new()
	self.audioModel = AudioModel:new()
	self.resourceModel = ResourceModel:new()

	for k, v in pairs(self) do
		v.game = self
	end

	for k, w in pairs(deps) do
		for _, v in ipairs(w) do
			dinject(self[k], v, self[v])
		end
	end
end

GameController.load = function(self)
	local configModel = self.configModel
	local rhythmModel = self.rhythmModel

	self.directoryManager:createDirectories()

	configModel:open("settings", true)
	configModel:open("select", true)
	configModel:open("modifier", true)
	configModel:open("input", true)
	configModel:open("mount", true)
	configModel:open("online", true)
	configModel:open("urls")
	configModel:open("judgements")
	configModel:open("filters")
	configModel:open("files")
	configModel:read()

	rhythmModel.timings = configModel.configs.settings.gameplay.timings
	rhythmModel.judgements = configModel.configs.judgements
	rhythmModel.hp = configModel.configs.settings.gameplay.hp
	rhythmModel.settings = configModel.configs.settings

	self.themeModel:load()
	self.modifierModel:load()
	self.mountModel:load()
	self.windowModel:load()
	self.scoreModel:load()
	self.onlineModel:load()
	self.noteSkinModel:load()
	self.cacheModel:load()
	self.noteChartModel:load()
	self.noteChartSetLibraryModel:load()
	self.noteChartLibraryModel:load()
	self.osudirectModel:load()
	self.discordModel:load()
	self.backgroundModel:load()
	self.collectionModel:load()
	self.selectModel:load()
	self.previewModel:load()
	self.audioModel:load()

	self.multiplayerController:load()

	self.onlineModel.authManager:checkSession()
	self.multiplayerModel:connect()

	self.gameView:load()
end

GameController.resetGameplayConfigs = function(self)
	self.modifierModel:setConfig(self.configModel.configs.modifier)
	self.rhythmModel.timings = self.configModel.configs.settings.gameplay.timings
end

GameController.unload = function(self)
	self.gameView:unload()
	self.discordModel:unload()
	self.mountModel:unload()
	self.multiplayerController:unload()
	self.configModel:write()
end

GameController.update = function(self, dt)
	self.discordModel:update()
	self.notificationModel:update()
	self.backgroundModel:update(dt)

	self.multiplayerController:update()
	self.osudirectModel:update()

	self.windowModel:update()
	self.cacheModel:update()

	self.gameView:update(dt)
end

GameController.draw = function(self)
	self.gameView:draw()
end

GameController.receive = function(self, event)
	if event.name == "update" then
		return self:update(event[1])
	elseif event.name == "draw" then
		return self:draw()
	elseif event.name == "quit" then
		return self:unload()
	end

	self.gameView:receive(event)
	self.windowModel:receive(event)
	self.screenshotModel:receive(event)
	self.mountController:receive(event)
end

return GameController
