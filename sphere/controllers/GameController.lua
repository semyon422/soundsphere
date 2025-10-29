local class = require("class")

local OnlineModel = require("sphere.models.OnlineModel")
local ModifierSelectModel = require("sphere.models.ModifierSelectModel")
local NoteSkinModel = require("sphere.models.NoteSkinModel")
local InputModel = require("sphere.models.InputModel")
local SelectModel = require("sphere.models.SelectModel")
local RhythmModel = require("sphere.models.RhythmModel")
local MultiplayerModel = require("sphere.models.MultiplayerModel")
local ReplayModel = require("sphere.models.ReplayModel")
local EditorModel = require("sphere.models.EditorModel")
local SpeedModel = require("sphere.models.SpeedModel")
local TimeRateModel = require("sphere.models.TimeRateModel")
local ResourceModel = require("sphere.models.ResourceModel")
local PauseModel = require("sphere.models.PauseModel")
local JoystickModel = require("sphere.models.JoystickModel")
local OffsetModel = require("sphere.models.OffsetModel")

local SelectController = require("sphere.controllers.SelectController")
local GameplayController = require("sphere.controllers.GameplayController")
local ResultController = require("sphere.controllers.ResultController")
local MultiplayerController = require("sphere.controllers.MultiplayerController")
local EditorController = require("sphere.controllers.EditorController")

local OffsetController = require("sphere.controllers.gameplay.OffsetController")

local NotificationModel = require("sphere.ui.NotificationModel")
local BackgroundModel = require("sphere.ui.BackgroundModel")
local PreviewModel = require("sphere.ui.PreviewModel")
local ChartPreviewModel = require("sphere.ui.ChartPreviewModel")

local Persistence = require("sphere.persistence.Persistence")
local App = require("sphere.app.App")
local UserInterfaceModel = require("sphere.models.UserInterfaceModel")

local PackageManager = require("sphere.pkg.PackageManager")
local SeaClient = require("sphere.online.SeaClient")
local OnlineClient = require("sphere.online.OnlineClient")
local OnlineWrapper = require("sphere.online.OnlineWrapper")
local DifftablesSync = require("sea.difftables.DifftablesSync")
local ClientRemote = require("sea.app.remotes.ClientRemote")

local ComputeContext = require("sea.compute.ComputeContext")
local ReplayBase = require("sea.replays.ReplayBase")

local LoveFilesystem = require("fs.LoveFilesystem")

local RhythmEngine = require("rizu.engine.RhythmEngine")

---@class sphere.GameController
---@operator call: sphere.GameController
local GameController = class()

function GameController:new()
	self.fs = LoveFilesystem()

	self.rhythm_engine = RhythmEngine(self.fs)

	self.packageManager = PackageManager()

	self.persistence = Persistence()
	self.app = App(self.persistence)
	self.uiModel = UserInterfaceModel(self)

	self.online_client = OnlineClient()
	self.client_remote = ClientRemote(self.online_client, self.persistence.cacheModel)
	self.seaClient = SeaClient(self.online_client, self.client_remote)
	self.difftables_sync = DifftablesSync(self.seaClient.remote.difftables, self.persistence.cacheModel.difftablesRepo)
	self.online_wrapper = OnlineWrapper(self.online_client, self.seaClient.remote)

	self.onlineModel = OnlineModel(self.persistence.configModel, self.seaClient)
	self.noteSkinModel = NoteSkinModel(self.persistence.configModel, self.packageManager)
	self.inputModel = InputModel(self.persistence.configModel)
	self.resourceModel = ResourceModel(
		self.persistence.configModel,
		self.persistence.fileFinder
	)
	self.pauseModel = PauseModel(self.persistence.configModel, self.rhythm_engine)
	self.replayModel = ReplayModel(self.rhythm_engine)
	self.editorModel = EditorModel(
		self.persistence.configModel,
		self.resourceModel
	)
	self.speedModel = SpeedModel(self.persistence.configModel)
	self.computeContext = ComputeContext()
	self.replayBase = ReplayBase()
	self.timeRateModel = TimeRateModel(self.replayBase)
	self.modifierSelectModel = ModifierSelectModel(self.replayBase)
	self.selectModel = SelectModel(
		self.persistence.configModel,
		self.persistence.cacheModel,
		self.onlineModel,
		self.replayBase
	)
	self.multiplayerModel = MultiplayerModel(
		self.persistence.cacheModel,
		self.rhythm_engine,
		self.persistence.configModel,
		self.selectModel,
		self.onlineModel,
		self.persistence.osudirectModel,
		self.replayBase
	)
	self.offsetModel = OffsetModel(
		self.persistence.configModel,
		self.persistence.cacheModel.chartsRepo
	)

	self.joystickModel = JoystickModel(self.persistence.configModel)

	self.cacheModel = self.persistence.cacheModel
	self.osudirectModel = self.persistence.osudirectModel
	self.configModel = self.persistence.configModel
	self.fileFinder = self.persistence.fileFinder
	self.difficultyModel = self.persistence.difficultyModel

	self.discordModel = self.app.discordModel
	self.windowModel = self.app.windowModel

	self.backgroundModel = BackgroundModel()
	self.notificationModel = NotificationModel()
	self.previewModel = PreviewModel(self.persistence.configModel)
	self.chartPreviewModel = ChartPreviewModel(
		self.persistence.configModel,
		self.previewModel,
		self.replayBase,
		self
	)

	self.selectController = SelectController(
		self.selectModel,
		self.modifierSelectModel,
		self.noteSkinModel,
		self.configModel,
		self.multiplayerModel,
		self.onlineModel,
		self.cacheModel,
		self.osudirectModel,
		self.windowModel,
		self.replayBase,
		self.backgroundModel,
		self.previewModel,
		self.chartPreviewModel
	)
	self.gameplayController = GameplayController(
		self.rhythm_engine,
		self.noteSkinModel,
		self.configModel,
		self.replayModel,
		self.multiplayerModel,
		self.discordModel,
		self.onlineModel,
		self.cacheModel,
		self.replayBase,
		self.computeContext,
		self.pauseModel,
		self.notificationModel,
		self.seaClient,
		self.fs
	)
	self.resultController = ResultController(
		self.selectModel,
		self.replayModel,
		self.rhythm_engine,
		self.onlineModel,
		self.configModel,
		self.computeContext,
		self.replayBase
	)
	self.multiplayerController = MultiplayerController(
		self.multiplayerModel,
		self.configModel,
		self.selectModel,
		self.replayBase
	)
	self.editorController = EditorController(
		self.selectModel,
		self.editorModel,
		self.noteSkinModel,
		self.configModel,
		self.resourceModel,
		self.windowModel,
		self.cacheModel,
		self.fileFinder,
		self.previewModel,
		self.replayBase
	)
	self.offsetController = OffsetController(
		self.cacheModel,
		self.computeContext,
		self.offsetModel,
		self.rhythm_engine,
		self.notificationModel
	)
end

function GameController:loadGameplay()
	local chartview = self.selectModel.chartview

	self.gameplayController:load(chartview)
	self.previewModel:stop()

	love.mouse.setVisible(false)

	self.windowModel:setVsyncOnSelect(false)
	self.multiplayerModel.client:setPlaying(true)
	self.offsetController:updateOffsets()

	local noteSkin = self.gameplayController.noteSkin

	local fileFinder = self.fileFinder
	fileFinder:reset()

	if self.configModel.configs.settings.gameplay.skin_resources_top_priority then
		fileFinder:addPath(noteSkin.directoryPath)
		fileFinder:addPath(chartview.location_dir)
	else
		fileFinder:addPath(chartview.location_dir)
		fileFinder:addPath(noteSkin.directoryPath)
	end
	fileFinder:addPath("userdata/hitsounds")
	fileFinder:addPath("userdata/hitsounds/midi")

	-- self.resourceModel:load(self.computeContext.chart, function()
	-- 	if not self.gameplayController.loaded then
	-- 		return
	-- 	end
	-- 	self.gameplayController:play()
	-- end)
end

function GameController:unloadGameplay()
	self.gameplayController:unload()

	love.mouse.setVisible(true)

	self.windowModel:setVsyncOnSelect(true)
	self.multiplayerModel.client:setPlaying(false)
end

---@param delta number
function GameController:increasePlaySpeed(delta)
	local speedModel = self.speedModel
	speedModel:increase(delta)

	local gameplay = self.configModel.configs.settings.gameplay
	self.rhythm_engine:setVisualRate(gameplay.speed)
	self.notificationModel:notify("scroll speed: " .. speedModel.format[gameplay.speedType]:format(speedModel:get()))
end

function GameController:load()
	self.packageManager:load()

	self.persistence:load()
	self.app:load()

	self.uiModel:load()
	self.ui = self.uiModel.activeUI

	local configModel = self.configModel
	local rhythm_engine = self.rhythm_engine

	rhythm_engine.judgements = configModel.configs.judgements
	rhythm_engine.hp = configModel.configs.settings.gameplay.hp
	rhythm_engine.settings = configModel.configs.settings

	self.replayBase:importReplayBase(configModel.configs.play)
	self.modifierSelectModel:updateAdded()

	self.seaClient:load(self.persistence.configModel.configs.urls.websocket, function()
		self.onlineModel:load()
		self.onlineModel.authManager:checkSession()
		self.online_wrapper:updateLeaderboards()
		if not love.filesystem.read("disable_difftables_sync.txt") then
			print("sync difftables", self.difftables_sync:sync())
		end
	end)

	self.noteSkinModel:load()
	self.osudirectModel:load()
	self.selectModel:load()

	self.multiplayerController:load()

	self.multiplayerModel:connect()

	self.backgroundModel:load()
	self.previewModel:load()
end

function GameController:unload()
	self.multiplayerController:unload()
	self.ui:unload()
	self.app:unload()
end

---@param dt number
function GameController:update(dt)
	self.app:update()

	self.joystickModel:update(dt)

	self.multiplayerController:update()
	self.osudirectModel:update()

	self.cacheModel:update()

	self.backgroundModel:update()
	self.chartPreviewModel:update()
	self.ui:update(dt)
	self.notificationModel:update()

	self.seaClient:update()
end

function GameController:draw()
	self.ui:draw()
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

	self.ui:receive(event)
	self.app:receive(event)
	self.joystickModel:receive(event)
end

return GameController
