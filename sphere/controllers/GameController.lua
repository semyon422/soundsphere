local class = require("class")

local OnlineModel = require("sphere.models.OnlineModel")
local ModifierSelectModel = require("sphere.models.ModifierSelectModel")
local NoteSkinModel = require("sphere.models.NoteSkinModel")
local InputModel = require("sphere.models.InputModel")
local DifficultyModel = require("sphere.models.DifficultyModel")
local ScoreLibraryModel = require("sphere.models.ScoreLibraryModel")
local SelectModel = require("sphere.models.SelectModel")
local RhythmModel = require("sphere.models.RhythmModel")
local MultiplayerModel = require("sphere.models.MultiplayerModel")
local ReplayModel = require("sphere.models.ReplayModel")
local EditorModel = require("sphere.models.EditorModel")
local SpeedModel = require("sphere.models.SpeedModel")
local TimeRateModel = require("sphere.models.TimeRateModel")
local ResourceModel = require("sphere.models.ResourceModel")
local PlayContext = require("sphere.models.PlayContext")
local PauseModel = require("sphere.models.PauseModel")

local SelectController = require("sphere.controllers.SelectController")
local GameplayController = require("sphere.controllers.GameplayController")
local FastplayController = require("sphere.controllers.FastplayController")
local ResultController = require("sphere.controllers.ResultController")
local MultiplayerController = require("sphere.controllers.MultiplayerController")
local EditorController = require("sphere.controllers.EditorController")

local Persistence = require("sphere.persistence.Persistence")
local App = require("sphere.app.App")
local UserInterface = require("sphere.ui.UserInterface")

---@class sphere.GameController
---@operator call: sphere.GameController
local GameController = class()

local deps = require("sphere.deps")

function GameController:new()
	self.persistence = Persistence()
	self.app = App(self.persistence)
	self.ui = UserInterface(self.persistence, self)

	self.selectController = SelectController()
	self.gameplayController = GameplayController()
	self.fastplayController = FastplayController()
	self.resultController = ResultController()
	self.multiplayerController = MultiplayerController()
	self.editorController = EditorController()

	self.onlineModel = OnlineModel(self.persistence.configModel)
	self.noteSkinModel = NoteSkinModel(self.persistence.configModel)
	self.inputModel = InputModel(self.persistence.configModel)
	self.difficultyModel = DifficultyModel()
	self.scoreLibraryModel = ScoreLibraryModel(
		self.persistence.configModel,
		self.onlineModel,
		self.persistence.scoreModel
	)
	self.selectModel = SelectModel(
		self.persistence.configModel,
		self.scoreLibraryModel,
		self.persistence.cacheModel
	)
	self.resourceModel = ResourceModel(
		self.persistence.configModel,
		self.persistence.fileFinder
	)
	self.rhythmModel = RhythmModel(
		self.inputModel,
		self.resourceModel
	)
	self.pauseModel = PauseModel(self.persistence.configModel, self.rhythmModel)
	self.replayModel = ReplayModel(self.rhythmModel)
	self.editorModel = EditorModel(
		self.persistence.configModel,
		self.resourceModel
	)
	self.speedModel = SpeedModel(self.persistence.configModel)
	self.playContext = PlayContext()
	self.timeRateModel = TimeRateModel(self.persistence.configModel, self.playContext)
	self.modifierSelectModel = ModifierSelectModel(self.playContext)
	self.multiplayerModel = MultiplayerModel(
		self.rhythmModel,
		self.persistence.configModel,
		self.selectModel,
		self.onlineModel,
		self.persistence.osudirectModel,
		self.playContext
	)

	self.scoreModel = self.persistence.scoreModel
	self.cacheModel = self.persistence.cacheModel
	self.osudirectModel = self.persistence.osudirectModel
	self.configModel = self.persistence.configModel
	self.fileFinder = self.persistence.fileFinder

	self.discordModel = self.app.discordModel
	self.mountModel = self.app.mountModel
	self.windowModel = self.app.windowModel

	self.backgroundModel = self.ui.backgroundModel
	self.notificationModel = self.ui.notificationModel
	self.previewModel = self.ui.previewModel

	self.gameView = self.ui.gameView
	self.selectView = self.ui.selectView
	self.resultView = self.ui.resultView
	self.gameplayView = self.ui.gameplayView
	self.multiplayerView = self.ui.multiplayerView
	self.editorView = self.ui.editorView

	for n, list in pairs(deps) do
		for _, m in ipairs(list) do
			self[n][m] = self[m]
		end
	end
end

function GameController:load()
	self.persistence:load()
	self.app:load()

	local configModel = self.configModel
	local rhythmModel = self.rhythmModel

	rhythmModel.judgements = configModel.configs.judgements
	rhythmModel.hp = configModel.configs.settings.gameplay.hp
	rhythmModel.settings = configModel.configs.settings

	self.playContext:load(configModel.configs.play)
	self.modifierSelectModel:updateAdded()

	self.scoreModel:load()
	self.onlineModel:load()
	self.noteSkinModel:load()
	self.cacheModel:load()
	self.osudirectModel:load()
	self.selectModel:load()

	self.multiplayerController:load()

	self.onlineModel.authManager:checkSession()
	self.multiplayerModel:connect()

	self.ui:load()
end

function GameController:unload()
	self.multiplayerController:unload()
	self.ui:unload()
	self.app:unload()
end

---@param dt number
function GameController:update(dt)
	self.app:update()

	self.multiplayerController:update()
	self.osudirectModel:update()

	self.cacheModel:update()

	self.ui:update(dt)
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
end

return GameController
