local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local GameplayNavigator = Navigator:new({construct = false})

GameplayNavigator.construct = function(self)
	Navigator.construct(self)
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

	if
		event.name == "focus" and
		not event.args[1] and
		self.state ~= "pause" and
		not self.rhythmModel.logicEngine.autoplay and
		self.rhythmModel.inputManager.mode ~= "internal"
	then
		self:forcePause()
	end
end

GameplayNavigator.update = function(self)
	local needRetry = self.rhythmModel.pauseManager.needRetry

	if needRetry then
		self:forceRetry()
	end

	local state = self.rhythmModel.pauseManager.state
	if state == "play" then
		self:removeSubscreen("pause")
	elseif state == "pause" then
		self:addSubscreen("pause")
	end
end

GameplayNavigator.keypressed = function(self, event)
	local state = self.rhythmModel.pauseManager.state

	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	local scancode = event.args[2]
	if state == "play" then
		if scancode == "escape" and not shift then self:pause()
		elseif scancode == "escape" and shift then self:quit()
		elseif scancode == "`" then self:retry()
		end
	elseif state == "pause" then
		if scancode == "up" then self:scrollMenu("up")
		elseif scancode == "down" then self:scrollMenu("down")
		elseif scancode == "return" then
		elseif scancode == "escape" and not shift then self:play()
		elseif scancode == "escape" and shift then self:quit()
		elseif scancode == "`" then self:retry()
		end
	elseif state == "pause-play" and scancode == "escape" then
		self:pause()
	end
end

GameplayNavigator.keyreleased = function(self, event)
	local state = self.rhythmModel.pauseManager.state

	local scancode = event.args[2]
	if state == "play-pause" and scancode == "escape" then
		self:play()
	elseif state == "pause-retry" and scancode == "`" then
		self:pause()
	elseif state == "play-retry" and scancode == "`" then
		self:play()
	end
end

GameplayNavigator.saveCamera = function(self, x, y, z, pitch, yaw)
	self:send({
		name = "saveCamera",
		x = x,
		y = y,
		z = z,
		pitch = pitch,
		yaw = yaw,
	})
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

GameplayNavigator.forcePause = function(self)
	self:send({
		name = "pause"
	})
end

GameplayNavigator.retry = function(self)
	self:send({
		name = "playStateChange",
		state = "retry"
	})
end

GameplayNavigator.forceRetry = function(self)
	self:send({
		name = "retry"
	})
end

GameplayNavigator.quit = function(self)
	self:send({
		name = "quit"
	})
end

return GameplayNavigator
