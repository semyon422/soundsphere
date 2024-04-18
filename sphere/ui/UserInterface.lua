local class = require("class")

local NotificationModel = require("sphere.ui.NotificationModel")
local ThemeModel = require("sphere.ui.ThemeModel")
local BackgroundModel = require("sphere.ui.BackgroundModel")
local PreviewModel = require("sphere.ui.PreviewModel")
local ChartPreviewModel = require("sphere.ui.ChartPreviewModel")

local GameView = require("sphere.views.GameView")
local SelectView = require("sphere.views.SelectView")
local ResultView = require("sphere.views.ResultView")
local GameplayView = require("sphere.views.GameplayView")
local MultiplayerView = require("sphere.views.MultiplayerView")
local EditorView = require("sphere.views.EditorView")

---@class sphere.UserInterface
---@operator call: sphere.UserInterface
local UserInterface = class()

---@param persistence sphere.Persistence
---@param game sphere.GameController
function UserInterface:new(persistence, game)
	self.backgroundModel = BackgroundModel()
	self.notificationModel = NotificationModel()
	self.previewModel = PreviewModel(persistence.configModel)
	self.chartPreviewModel = ChartPreviewModel(persistence.configModel)
	self.themeModel = ThemeModel()

	self.gameView = GameView(game)
	self.selectView = SelectView(game)
	self.resultView = ResultView(game)
	self.gameplayView = GameplayView(game)
	self.multiplayerView = MultiplayerView(game)
	self.editorView = EditorView(game)
end

function UserInterface:load()
	self.themeModel:load()
	self.backgroundModel:load()
	self.previewModel:load()

	self.gameView:load()
end

function UserInterface:unload()
	self.gameView:unload()
end

---@param dt number
function UserInterface:update(dt)
	self.notificationModel:update()
	self.backgroundModel:update()

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
