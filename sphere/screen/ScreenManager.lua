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
			local ok, err = xpcall(screen.load, debug.traceback, screen)
			if not ok then
				pcall(screen.unload, screen)
				screen = self.fallback
				if not screen then
					error(err)
				end
				self.currentScreen = screen
				assert(xpcall(screen.load, debug.traceback, screen))
				screen.error = err
			end
			self.transition:fadeOut()
			coroutine.yield()
		end
	end)
	coroutine.resume(self.coroutine)
end

ScreenManager.setFallback = function(self, screen)
	self.fallback = screen
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
