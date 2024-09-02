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
local PlayContext = require("sphere.models.PlayContext")
local PauseModel = require("sphere.models.PauseModel")
local JoystickModel = require("sphere.models.JoystickModel")
local OffsetModel = require("sphere.models.OffsetModel")

local SelectController = require("sphere.controllers.SelectController")
local GameplayController = require("sphere.controllers.GameplayController")
local FastplayController = require("sphere.controllers.FastplayController")
local ResultController = require("sphere.controllers.ResultController")
local MultiplayerController = require("sphere.controllers.MultiplayerController")
local EditorController = require("sphere.controllers.EditorController")

local Persistence = require("sphere.persistence.Persistence")
local App = require("sphere.app.App")
local UserInterfaceModel = require("sphere.models.UserInterfaceModel")

---@class sphere.GameController
---@operator call: sphere.GameController
local GameController = class()

function GameController:new()
	self.persistence = Persistence()
	self.app = App(self.persistence)
	self.uiModel = UserInterfaceModel(self.persistence, self)

	self.onlineModel = OnlineModel(self.persistence.configModel)
	self.noteSkinModel = NoteSkinModel(self.persistence.configModel)
	self.inputModel = InputModel(self.persistence.configModel)
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
	self.selectModel = SelectModel(
		self.persistence.configModel,
		self.persistence.cacheModel,
		self.onlineModel,
		self.playContext
	)
	self.multiplayerModel = MultiplayerModel(
		self.persistence.cacheModel,
		self.rhythmModel,
		self.persistence.configModel,
		self.selectModel,
		self.onlineModel,
		self.persistence.osudirectModel,
		self.playContext
	)
	self.offsetModel = OffsetModel(
		self.persistence.configModel,
		self.selectModel
	)

	self.joystickModel = JoystickModel(self.persistence.configModel)

	self.cacheModel = self.persistence.cacheModel
	self.osudirectModel = self.persistence.osudirectModel
	self.configModel = self.persistence.configModel
	self.fileFinder = self.persistence.fileFinder
	self.difficultyModel = self.persistence.difficultyModel

	self.discordModel = self.app.discordModel
	self.windowModel = self.app.windowModel

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
		self.playContext,
		self.uiModel
	)
	self.gameplayController = GameplayController(
		self.rhythmModel,
		self.selectModel,
		self.noteSkinModel,
		self.configModel,
		self.difficultyModel,
		self.replayModel,
		self.multiplayerModel,
		self.discordModel,
		self.onlineModel,
		self.resourceModel,
		self.windowModel,
		self.speedModel,
		self.cacheModel,
		self.fileFinder,
		self.playContext,
		self.pauseModel,
		self.offsetModel,
		self.uiModel
	)
	self.fastplayController = FastplayController(
		self.rhythmModel,
		self.replayModel,
		self.cacheModel,
		self.playContext
	)
	self.resultController = ResultController(
		self.selectModel,
		self.replayModel,
		self.rhythmModel,
		self.onlineModel,
		self.configModel,
		self.fastplayController,
		self.playContext
	)
	self.multiplayerController = MultiplayerController(
		self.multiplayerModel,
		self.configModel,
		self.selectModel,
		self.playContext
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
		self.uiModel
	)
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

	self.onlineModel:load()
	self.noteSkinModel:load()
	self.osudirectModel:load()
	self.selectModel:load()

	self.multiplayerController:load()

	self.onlineModel.authManager:checkSession()
	self.multiplayerModel:connect()

	self.uiModel:load()
	self.ui = self.uiModel.activeUI
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
	self.joystickModel:receive(event)
end

return GameController
