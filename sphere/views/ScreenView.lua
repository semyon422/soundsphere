local class = require("class")

---@class sphere.ScreenView
local ScreenView = class()

---@param game sphere.GameController
function ScreenView:new(game)
	self.game = game
end

---@param screenName string
function ScreenView:changeScreen(screenName)
	self:beginUnload()
	self.gameView:setView(self.game.ui[screenName])
end

function ScreenView:load() end
function ScreenView:beginUnload() end
function ScreenView:unload() end

---@param event table
function ScreenView:receive(event) end

---@param dt number
function ScreenView:update(dt) end

function ScreenView:draw() end

return ScreenView
