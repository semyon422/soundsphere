local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local GameplayNavigator = Navigator:new()

GameplayNavigator.construct = function(self)
	-- self.itemIndex = 1
	-- self.inputItemIndex = 1
	-- self.virtualKey = ""
	-- self.activeElement = "list"
	self.state = "play"
end

GameplayNavigator.receive = function(self, event)
	if event.name == "keypressed" then
		return self:keypressed(event)
	elseif event.name == "keyreleased" then
		return self:keyreleased(event)
	end
end

GameplayNavigator.keypressed = function(self, event)
	local state = self.rhythmModel.pauseManager.state

	local scancode = event.args[2]
	if state == "play" and scancode == "escape" then
		self:pause()
	elseif state == "pause" then
		if scancode == "up" then self:scrollMenu("up")
		elseif scancode == "down" then self:scrollMenu("down")
		elseif scancode == "return" then
		elseif scancode == "escape" then self:play()
		elseif scancode == "`" then self:retry()
		end
	elseif state == "pause-play" and scancode == "escape" then
		self:pause()
	end
end

GameplayNavigator.keyreleased = function(self, event)
	local state = self.rhythmModel.pauseManager.state

	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	local scancode = event.args[2]
	if shift and scancode == "escape" then
		return self:quit()
	end

	if state == "play-pause" and scancode == "escape" then
		self:play()
	elseif state == "pause-retry" and scancode == "`" then
		self:pause()
	elseif state == "play-retry" and scancode == "`" then
		self:play()
	end
end

GameplayNavigator.play = function(self)
	self:send({
		name = "playStateChange",
		state = "play"
	})
end

GameplayNavigator.pause = function(self)
	self:send({
		name = "playStateChange",
		state = "pause"
	})
end

GameplayNavigator.retry = function(self)
	self:send({
		name = "playStateChange",
		state = "retry"
	})
end

GameplayNavigator.quit = function(self)
	self:send({
		name = "quit"
	})
end

return GameplayNavigator
