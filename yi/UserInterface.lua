local IUserInterface = require("sphere.IUserInterface")
local Context = require("yi.Context")
local View = require("yi.views.View")
local Inputs = require("ui.input.Inputs")
local Engine = require("yi.Engine")
local Background = require("yi.views.Background")
local Screens = require("yi.views.Screens")

---@class yi.UserInterface
---@overload fun(game: sphere.GameController): yi.UserInterface
local UserInterface = IUserInterface + {}

---@param game sphere.GameController
function UserInterface:new(game)
	self.game = game

	self.inputs = Inputs()
	self.ctx = Context(self.game, self.inputs)
	self.engine = Engine(self.inputs, self.ctx)
end

function UserInterface:load()
	self.game.selectController:load()
	local root = self.engine.root

	local background = root:add(Background())
	local screens = root:add(Screens())
	local modals = root:add(View())
	local top = root:add(View()) -- Cursor, Tooltip, Notifications, Dropdown items

	self.ctx:setLayers(background, screens, modals, top)
	self.engine:load()

	screens:set("select")

	self.screens = screens
end

---@param dt number
function UserInterface:update(dt)
	self.game.selectController:update()
	self.engine:update(dt, love.mouse.getPosition())
end

function UserInterface:draw()
	self.engine:draw()
end

---@param event table
function UserInterface:receive(event)
	self.screens:receive(event) -- :sob:
	self.engine:receive(event)
end

return UserInterface
