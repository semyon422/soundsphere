local Screen = require("sphere.screen.Screen")
local TransitionManager = require("sphere.screen.TransitionManager")

local ScreenManager = {}

ScreenManager.currentScreen = Screen:new()

ScreenManager.set = function(self, screen, callback)
	TransitionManager:transit(function()
		self.currentScreen:unload()
		self.currentScreen = screen
		screen:load()
		if callback then
			callback()
		end
	end)
end

ScreenManager.update = function(self, dt)
	self.currentScreen:update(dt)
	TransitionManager:update(dt)
end

ScreenManager.draw = function(self)
	TransitionManager:drawBefore()
	self.currentScreen:draw()
	TransitionManager:drawAfter()
end

ScreenManager.receive = function(self, event)
	self.currentScreen:receive(event)
end

ScreenManager.unload = function(self)
	self.currentScreen:unload()
end

return ScreenManager
