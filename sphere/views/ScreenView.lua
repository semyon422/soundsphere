local class = require("class")

local ScreenView = class()

function ScreenView:changeScreen(screenName, noTransition)
	self:beginUnload()
	self.gameView:setView(self.game[screenName], noTransition)
end

function ScreenView:load() end
function ScreenView:beginUnload() end
function ScreenView:unload() end
function ScreenView:receive(event) end
function ScreenView:update(dt) end
function ScreenView:draw() end

return ScreenView
