local class = require("class")
local ConfigModel = require("sphere.models.ConfigModel")
local ScoreModel = require("sphere.models.ScoreModel")
local DiscordModel = require("sphere.models.DiscordModel")
local MountModel = require("sphere.models.MountModel")
local WindowModel = require("sphere.models.WindowModel")
local DirectoryManager = require("sphere.filesystem.DirectoryManager")
local NotificationModel = require("sphere.models.NotificationModel")
local ThemeModel = require("sphere.models.ThemeModel")
local OnlineModel = require("sphere.models.OnlineModel")
local BackgroundModel = require("sphere.models.BackgroundModel")
local NoteChartModel = require("sphere.models.NoteChartModel")
local ModifierModel = require("sphere.models.ModifierModel")
local NoteSkinModel = require("sphere.models.NoteSkinModel")
local InputModel = require("sphere.models.InputModel")
local CacheModel = require("sphere.models.CacheModel")
local DifficultyModel = require("sphere.models.DifficultyModel")
local CollectionModel = require("sphere.models.CollectionModel")
local ScoreLibraryModel = require("sphere.models.ScoreLibraryModel")
local SelectModel = require("sphere.models.SelectModel")
local PreviewModel = require("sphere.models.PreviewModel")
local UpdateModel = require("sphere.models.UpdateModel")
local RhythmModel = require("sphere.models.RhythmModel")
local OsudirectModel = require("sphere.models.OsudirectModel")
local MultiplayerModel = require("sphere.models.MultiplayerModel")
local ReplayModel = require("sphere.models.ReplayModel")
local EditorModel = require("sphere.models.EditorModel")
local SpeedModel = require("sphere.models.SpeedModel")
local ScreenshotModel = require("sphere.models.ScreenshotModel")
local AudioModel = require("sphere.models.AudioModel")
local ResourceModel = require("sphere.models.ResourceModel")

local MountController = require("sphere.controllers.MountController")
local SelectController = require("sphere.controllers.SelectController")
local GameplayController = require("sphere.controllers.GameplayController")
local FastplayController = require("sphere.controllers.FastplayController")
local ResultController = require("sphere.controllers.ResultController")
local MultiplayerController = require("sphere.controllers.MultiplayerController")
local EditorController = require("sphere.controllers.EditorController")

local GameView = require("sphere.views.GameView")
local SelectView = require("sphere.views.SelectView")
local ResultView = require("sphere.views.ResultView")
local GameplayView = require("sphere.views.GameplayView")
local MultiplayerView = require("sphere.views.MultiplayerView")
local EditorView = require("sphere.views.EditorView")

---@class sphere.GameController
---@operator call: sphere.GameController
local GameController = class()

local deps = require("sphere.deps")

function GameController:new()
	self.game = self

	self.mountController = MountController()
	self.selectController = SelectController()
	self.gameplayController = GameplayController()
	self.fastplayController = FastplayController()
	self.resultController = ResultController()
	self.multiplayerController = MultiplayerController()
	self.editorController = EditorController()

	self.gameView = GameView()
	self.selectView = SelectView()
	self.resultView = ResultView()
	self.gameplayView = GameplayView()
	self.multiplayerView = MultiplayerView()
	self.editorView = EditorView()

	self.directoryManager = DirectoryManager()

	self.configModel = ConfigModel()
	self.notificationModel = NotificationModel()
	self.windowModel = WindowModel()
	self.mountModel = MountModel()
	self.screenshotModel = ScreenshotModel()
	self.themeModel = ThemeModel()
	self.scoreModel = ScoreModel()
	self.onlineModel = OnlineModel()
	self.cacheModel = CacheModel()
	self.backgroundModel = BackgroundModel()
	self.modifierModel = ModifierModel()
	self.noteSkinModel = NoteSkinModel()
	self.noteChartModel = NoteChartModel()
	self.inputModel = InputModel()
	self.difficultyModel = DifficultyModel()
	self.collectionModel = CollectionModel()
	self.scoreLibraryModel = ScoreLibraryModel()
	self.selectModel = SelectModel()
	self.previewModel = PreviewModel()
	self.updateModel = UpdateModel()
	self.rhythmModel = RhythmModel()
	self.discordModel = DiscordModel()
	self.osudirectModel = OsudirectModel()
	self.multiplayerModel = MultiplayerModel()
	self.replayModel = ReplayModel()
	self.editorModel = EditorModel()
	self.speedModel = SpeedModel()
	self.audioModel = AudioModel()
	self.resourceModel = ResourceModel()

	for n, list in pairs(deps) do
		for _, m in ipairs(list) do
			self[n][m] = self[m]
		end
	end
end

function GameController:load()
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

	self.modifierModel:setConfig(configModel.configs.modifier)

	self.themeModel:load()
	self.mountModel:load()
	self.windowModel:load()
	self.scoreModel:load()
	self.onlineModel:load()
	self.noteSkinModel:load()
	self.cacheModel:load()
	self.noteChartModel:load()
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

function GameController:unload()
	self.gameView:unload()
	self.discordModel:unload()
	self.mountModel:unload()
	self.multiplayerController:unload()
	self.configModel:write()
end

---@param dt number
function GameController:update(dt)
	self.discordModel:update()
	self.notificationModel:update()
	self.backgroundModel:update()

	self.multiplayerController:update()
	self.osudirectModel:update()

	self.windowModel:update()
	self.cacheModel:update()

	self.gameView:update(dt)
end

function GameController:draw()
	self.gameView:draw()
end

---@param event table
function GameController:receive(event)
	if event.name == "update" then
		self:update(event[1])
		return
	elseif event.name == "draw" then
		self:draw()
		return
	elseif event.name == "quit" then
		self:unload()
		return
	end

	self.gameView:receive(event)
	self.windowModel:receive(event)
	self.screenshotModel:receive(event)
	self.mountController:receive(event)
end

return GameController
