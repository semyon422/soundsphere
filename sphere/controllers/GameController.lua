local class = require("class")

local ScoreModel = require("sphere.models.ScoreModel")
local OnlineModel = require("sphere.models.OnlineModel")
local ModifierModel = require("sphere.models.ModifierModel")
local NoteSkinModel = require("sphere.models.NoteSkinModel")
local InputModel = require("sphere.models.InputModel")
local CacheModel = require("sphere.models.CacheModel")
local DifficultyModel = require("sphere.models.DifficultyModel")
local ScoreLibraryModel = require("sphere.models.ScoreLibraryModel")
local SelectModel = require("sphere.models.SelectModel")
local RhythmModel = require("sphere.models.RhythmModel")
local OsudirectModel = require("sphere.models.OsudirectModel")
local MultiplayerModel = require("sphere.models.MultiplayerModel")
local ReplayModel = require("sphere.models.ReplayModel")
local EditorModel = require("sphere.models.EditorModel")
local SpeedModel = require("sphere.models.SpeedModel")
local ResourceModel = require("sphere.models.ResourceModel")

local SelectController = require("sphere.controllers.SelectController")
local GameplayController = require("sphere.controllers.GameplayController")
local FastplayController = require("sphere.controllers.FastplayController")
local ResultController = require("sphere.controllers.ResultController")
local MultiplayerController = require("sphere.controllers.MultiplayerController")
local EditorController = require("sphere.controllers.EditorController")

local App = require("sphere.app.App")
local UserInterface = require("sphere.ui.UserInterface")

---@class sphere.GameController
---@operator call: sphere.GameController
local GameController = class()

local deps = require("sphere.deps")

function GameController:new()
	self.game = self

	self.app = App()
	self.ui = UserInterface(self.app)

	self.selectController = SelectController()
	self.gameplayController = GameplayController()
	self.fastplayController = FastplayController()
	self.resultController = ResultController()
	self.multiplayerController = MultiplayerController()
	self.editorController = EditorController()

	self.scoreModel = ScoreModel()
	self.onlineModel = OnlineModel()
	self.cacheModel = CacheModel()
	self.modifierModel = ModifierModel()
	self.noteSkinModel = NoteSkinModel()
	self.inputModel = InputModel()
	self.difficultyModel = DifficultyModel()
	self.scoreLibraryModel = ScoreLibraryModel()
	self.selectModel = SelectModel()
	self.rhythmModel = RhythmModel()
	self.osudirectModel = OsudirectModel()
	self.multiplayerModel = MultiplayerModel()
	self.replayModel = ReplayModel()
	self.editorModel = EditorModel()
	self.speedModel = SpeedModel()
	self.resourceModel = ResourceModel()

	self.configModel = self.app.configModel
	self.discordModel = self.app.discordModel
	self.mountModel = self.app.mountModel
	self.windowModel = self.app.windowModel
	self.fileFinder = self.app.fileFinder

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
	self.app:load()

	local configModel = self.configModel
	local rhythmModel = self.rhythmModel

	rhythmModel.timings = configModel.configs.settings.gameplay.timings
	rhythmModel.judgements = configModel.configs.judgements
	rhythmModel.hp = configModel.configs.settings.gameplay.hp
	rhythmModel.settings = configModel.configs.settings

	self.modifierModel:setConfig(configModel.configs.modifier)

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
