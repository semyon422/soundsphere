local IUserInterface = require("sphere.IUserInterface")

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
	self.gameView = GameView(game, self)
	self.selectView = SelectView(game)
	self.resultView = ResultView(game)
	self.gameplayView = GameplayView(game)
	self.multiplayerView = MultiplayerView(game)
	self.editorView = EditorView(game)
end

function UserInterface:load()
	self.gameView:load()
end

function UserInterface:unload()
	self.gameView:unload()
end

---@param dt number
function UserInterface:update(dt)
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
