local Screen			= require("sphere.screen.Screen")

local ScreenManager = {}

ScreenManager.init = function(self)
	self.currentScreen = Screen:new()
end

ScreenManager.set = function(self, screen, callback)
	self.transition:transit(function()
		self.currentScreen:unload()
		self.currentScreen = screen
		screen:load()
		if callback then
			callback()
		end
	end)
end

ScreenManager.setTransition = function(self, transition)
	self.transition = transition
end

ScreenManager.update = function(self, dt)
	self.currentScreen:update(dt)
	self.transition:update(dt)
end

ScreenManager.draw = function(self)
	self.transition:drawBefore()
	self.currentScreen:draw()
	self.transition:drawAfter()
end

ScreenManager.receive = function(self, event)
	self.currentScreen:receive(event)
end

ScreenManager.unload = function(self)
	self.currentScreen:unload()
end

ScreenManager:init()

return ScreenManager
