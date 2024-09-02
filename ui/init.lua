local IUserInterface = require("sphere.IUserInterface")

local NotificationModel = require("ui.models.NotificationModel")
local BackgroundModel = require("ui.models.BackgroundModel")
local PreviewModel = require("ui.models.PreviewModel")
local ChartPreviewModel = require("ui.models.ChartPreviewModel")

local GameView = require("ui.views.GameView")
local SelectView = require("ui.views.SelectView")
local ResultView = require("ui.views.ResultView")
local GameplayView = require("ui.views.GameplayView")
local MultiplayerView = require("ui.views.MultiplayerView")
local EditorView = require("ui.views.EditorView")

---@class ui.UserInterface : sphere.IUserInterface
---@operator call: ui.UserInterface
---@field selectView ui.ScreenView
local UserInterface = IUserInterface + {}

---@param persistence sphere.Persistence
---@param game sphere.GameController
function UserInterface:new(persistence, game)
	self.backgroundModel = BackgroundModel()
	self.notificationModel = NotificationModel()
	self.previewModel = PreviewModel(persistence.configModel)
	self.chartPreviewModel = ChartPreviewModel(persistence.configModel, self.previewModel, game)

	self.gameView = GameView(game, self)
	self.selectView = SelectView(game)
	self.resultView = ResultView(game)
	self.gameplayView = GameplayView(game)
	self.multiplayerView = MultiplayerView(game)
	self.editorView = EditorView(game)
end

function UserInterface:load()
	self.backgroundModel:load()
	self.previewModel:load()
	self.gameView:load()
end

function UserInterface:unload()
	self.previewModel:stop()
	self.gameView:unload()
end

---@param dt number
function UserInterface:update(dt)
	self.backgroundModel:update()
	self.chartPreviewModel:update()
	self.gameView:update(dt)
end

function UserInterface:draw()
	self.gameView:draw()
end

---@param event table
function UserInterface:receive(event)
	self.gameView:receive(event)
end

return UserInterface
