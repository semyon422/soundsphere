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
		not event[1] and
		self.state ~= "pause" and
		not self.gameController.rhythmModel.logicEngine.autoplay and
		self.gameController.rhythmModel.inputManager.mode ~= "internal"
	then
		self:forcePause()
	end
end

GameplayNavigator.update = function(self)
	local needRetry = self.gameController.rhythmModel.pauseManager.needRetry

	if needRetry then
		self:forceRetry()
	end

	local state = self.gameController.rhythmModel.pauseManager.state
	if state == "play" then
		self:removeSubscreen("pause")
	elseif state == "pause" then
		self:addSubscreen("pause")
	end

	local timeEngine = self.gameController.rhythmModel.timeEngine
	if timeEngine.currentTime >= timeEngine.maxTime + 1 and not self.quited then
		self:quit()
	end

	local pauseOnFail = self.gameController.configModel.configs.settings.gameplay.pauseOnFail
	local failed = self.gameController.rhythmModel.scoreEngine.scoreSystem.hp.failed
	if pauseOnFail and failed and not self.failed then
		self:pause()
		self.failed = true
	end

	Navigator.update(self)
end

GameplayNavigator.keypressed = function(self, event)
	local state = self.gameController.rhythmModel.pauseManager.state

	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	local scancode = event[2]

	local input = self.gameController.configModel.configs.settings.input

	if scancode == input.skipIntro then self:skipIntro()
	elseif scancode == input.offset.decrease then self:increaseLocalOffset(-0.001)
	elseif scancode == input.offset.increase then self:increaseLocalOffset(0.001)
	elseif scancode == input.timeRate.decrease then self:increaseTimeRate(-0.05)
	elseif scancode == input.timeRate.increase then self:increaseTimeRate(0.05)
	elseif scancode == input.timeRate.invert then self:invertTimeRate()
	elseif scancode == input.playSpeed.decrease then self:increasePlaySpeed(-0.05)
	elseif scancode == input.playSpeed.increase then self:increasePlaySpeed(0.05)
	elseif scancode == input.playSpeed.invert then self:invertPlaySpeed()
	end

	if scancode == "f1" then self:switchSubscreen("debug") end
	if state == "play" then
		if scancode == input.pause and not shift then self:pause()
		elseif scancode == input.pause and shift then self:quit()
		elseif scancode == input.quickRestart then self:retry()
		end
	elseif state == "pause" then
		if scancode == input.pause and not shift then self:play()
		elseif scancode == input.pause and shift then self:quit()
		elseif scancode == input.quickRestart then self:retry()
		end
	elseif state == "pause-play" and scancode == input.pause then
		self:pause()
	end
end

GameplayNavigator.keyreleased = function(self, event)
	local state = self.gameController.rhythmModel.pauseManager.state
	local input = self.gameController.configModel.configs.settings.input

	local scancode = event[2]
	if state == "play-pause" and scancode == input.pause then
		self:play()
	elseif state == "pause-retry" and scancode == input.quickRestart then
		self:pause()
	elseif state == "play-retry" and scancode == input.quickRestart then
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

GameplayNavigator.skipIntro = function(self)
	self:send({
		name = "skipIntro",
	})
end

GameplayNavigator.increaseLocalOffset = function(self, delta)
	self:send({
		name = "increaseLocalOffset",
		delta = delta
	})
end

GameplayNavigator.increaseTimeRate = function(self, delta)
	self:send({
		name = "increaseTimeRate",
		delta = delta
	})
end

GameplayNavigator.invertTimeRate = function(self)
	self:send({
		name = "invertTimeRate"
	})
end

GameplayNavigator.increasePlaySpeed = function(self, delta)
	self:send({
		name = "increasePlaySpeed",
		delta = delta
	})
end

GameplayNavigator.invertPlaySpeed = function(self)
	self:send({
		name = "invertPlaySpeed"
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
	self.quited = true
end

return GameplayNavigator
