local class = require("class")

local OnlineModel = require("sphere.models.OnlineModel")
local ModifierSelectModel = require("sphere.models.ModifierSelectModel")
local NoteSkinModel = require("sphere.models.NoteSkinModel")
local InputModel = require("sphere.models.InputModel")
local SelectModel = require("sphere.models.SelectModel")
local MultiplayerModel = require("sphere.models.MultiplayerModel")
local EditorModel = require("sphere.models.EditorModel")
local SpeedModel = require("sphere.models.SpeedModel")
local TimeRateModel = require("sphere.models.TimeRateModel")
local ResourceModel = require("sphere.models.ResourceModel")
local PauseModel = require("sphere.models.PauseModel")
local JoystickModel = require("sphere.models.JoystickModel")
local OffsetModel = require("sphere.models.OffsetModel")

local SelectController = require("sphere.controllers.SelectController")
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

local GameplayInteractor = require("rizu.gameplay.GameplayInteractor")
local GameInteractor = require("rizu.game.GameInteractor")

local ResourceLoader = require("rizu.files.ResourceLoader")
local ResourceFinder = require("rizu.files.ResourceFinder")

local RhythmEngine = require("rizu.engine.RhythmEngine")

local GlobalTimer = require("rizu.game.GlobalTimer")

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
	self.resultController = ResultController(self)
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

	self.resource_finder = ResourceFinder(self.fs)
	self.resource_loader = ResourceLoader(self.fs, self.resource_finder)

	self.gameplayInteractor = GameplayInteractor(self)
	self.gameInteractor = GameInteractor(self)

	self.global_timer = GlobalTimer()
end

function GameController:load()
	self.packageManager:load()

	self.persistence:load()
	self.app:load()

	self.uiModel:load()
	self.ui = self.uiModel.activeUI

	local configModel = self.configModel

	self.replayBase:importReplayBase(configModel.configs.play)
	self.modifierSelectModel:updateAdded()

	self.seaClient:load(self.persistence.configModel.configs.urls.websocket, function()
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
	self.gameplayInteractor:update()
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

	if event.name == "framestarted" then
		self.global_timer:setTime(event.time)
	end

	self.ui:receive(event)
	self.app:receive(event)
	self.joystickModel:receive(event)
end

return GameController
