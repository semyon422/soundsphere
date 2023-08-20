local class = require("class")

---@class sphere.ScreenView
local ScreenView = class()

---@param screenName string
---@param noTransition boolean?
function ScreenView:changeScreen(screenName, noTransition)
	self:beginUnload()
	self.gameView:setView(self.game[screenName], noTransition)
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
