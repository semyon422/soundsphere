local Screen			= require("sphere.screen.Screen")

local ScreenManager = {}

ScreenManager.init = function(self)
	self.currentScreen = Screen:new()
end

ScreenManager.set = function(self, screen)
	self.coroutine = coroutine.create(function()
		self.transition:fadeIn()
		self.currentScreen:unload()
		self.currentScreen = screen
		screen:load()
		self.transition:fadeOut()
	end)
	coroutine.resume(self.coroutine)
end

ScreenManager.setTransition = function(self, transition)
	self.transition = transition
end

ScreenManager.update = function(self, dt)
	self.currentScreen:update(dt)

	local transition = self.transition
	transition:update(dt)
	if transition.transiting and transition.complete then
		coroutine.resume(self.coroutine)
	end
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
