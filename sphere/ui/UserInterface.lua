local class = require("class")

local NotificationModel = require("sphere.ui.NotificationModel")
local ThemeModel = require("sphere.ui.ThemeModel")
local BackgroundModel = require("sphere.ui.BackgroundModel")
local PreviewModel = require("sphere.ui.PreviewModel")

local GameView = require("sphere.views.GameView")
local SelectView = require("sphere.views.SelectView")
local ResultView = require("sphere.views.ResultView")
local GameplayView = require("sphere.views.GameplayView")
local MultiplayerView = require("sphere.views.MultiplayerView")
local EditorView = require("sphere.views.EditorView")

---@class sphere.UserInterface
---@operator call: sphere.UserInterface
local UserInterface = class()

---@param app sphere.App
function UserInterface:new(app)
	self.backgroundModel = BackgroundModel()
	self.notificationModel = NotificationModel()
	self.previewModel = PreviewModel(app.configModel)
	self.themeModel = ThemeModel()

	self.gameView = GameView()
	self.selectView = SelectView()
	self.resultView = ResultView()
	self.gameplayView = GameplayView()
	self.multiplayerView = MultiplayerView()
	self.editorView = EditorView()
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
