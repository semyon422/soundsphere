local IUserInterface = require("sphere.IUserInterface")
local Context = require("yi.Context")
local View = require("yi.views.View")
local Inputs = require("ui.input.Inputs")
local Engine = require("yi.Engine")

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
	local root = self.engine.root
	local top = root:add(View()) -- Cursor, Tooltip, Notifications, Dropdown items
	local modals = root:add(View())
	local screens = root:add(View())
	local background = root:add(View()) -- Background image class
	self.ctx:setLayers(top, modals, screens, background) ---@diagnostic disable-line Temporary
	self.engine:load()
end

---@param dt number
function UserInterface:update(dt)
	self.engine:update(dt, love.mouse.getPosition())
end

function UserInterface:draw()
	self.engine:draw()
end

---@param event table
function UserInterface:receive(event)
	self.engine:receive(event)
end

return UserInterface
