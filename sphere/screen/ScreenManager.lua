local Screen = require("sphere.screen.Screen")

local ScreenManager = {}

ScreenManager.currentScreen = Screen:new()

ScreenManager.set = function(self, screen)
	self.currentScreen:unload()
	self.currentScreen = screen
	screen:load()
end

ScreenManager.update = function(self, dt)
	self.currentScreen:update(dt)
end

ScreenManager.draw = function(self)
	self.currentScreen:draw()
end

ScreenManager.receive = function(self, event)
	self.currentScreen:receive(event)
end

ScreenManager.unload = function(self)
	self.currentScreen:unload()
end

return ScreenManager
