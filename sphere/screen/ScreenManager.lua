local Class = require("aqua.util.Class")
local Screen = require("sphere.screen.Screen")

local ScreenManager = Class:new()

ScreenManager.construct = function(self)
	self.currentScreen = Screen:new()
	self.coroutine = coroutine.create(function()
		while true do
			self.waitForScreen = true
			local screen = coroutine.yield()
			self.waitForScreen = false
			self.transition:fadeIn()
			coroutine.yield()
			self.currentScreen:unload()
			self.currentScreen = screen
			self.screenToLoad = screen
			self.transition:fadeOut()
			coroutine.yield()
		end
	end)
	coroutine.resume(self.coroutine)
end

ScreenManager.set = function(self, screen)
	if not self.waitForScreen then
		return
	end
	assert(coroutine.resume(self.coroutine, screen))
end

ScreenManager.setTransition = function(self, transition)
	self.transition = transition
end

ScreenManager.update = function(self, dt)
	self.currentScreen:update(dt)

	local transition = self.transition
	transition:update(dt)
	if transition.needResume then
		assert(coroutine.resume(self.coroutine))
		transition.needResume = false
	end

	if self.screenToLoad then
		self.screenToLoad:load()
		self.screenToLoad = nil
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

return ScreenManager
