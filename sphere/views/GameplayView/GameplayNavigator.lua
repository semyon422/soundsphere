local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local GameplayNavigator = Navigator:new({construct = false})

GameplayNavigator.state = "play"

GameplayNavigator.load = function(self)
	self.failed = false
	Navigator.load(self)
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
		not self.game.rhythmModel.logicEngine.autoplay and
		not self.game.multiplayerModel.isPlaying and
		self.game.rhythmModel.inputManager.mode ~= "internal"
	then
		self:forcePause()
	end
end

GameplayNavigator.update = function(self)
	local needRetry = self.game.rhythmModel.pauseManager.needRetry

	if needRetry then
		self:forceRetry()
	end

	local state = self.game.rhythmModel.pauseManager.state
	if state == "play" then
		self:removeSubscreen("pause")
	elseif state == "pause" then
		self:addSubscreen("pause")
	end

	local timeEngine = self.game.rhythmModel.timeEngine
	if timeEngine.currentTime >= timeEngine.maxTime + 1 then
		self:quit()
	end

	local pauseOnFail = self.game.configModel.configs.settings.gameplay.pauseOnFail
	local failed = self.game.rhythmModel.scoreEngine.scoreSystem.hp.failed
	if pauseOnFail and failed and not self.failed then
		self:pause()
		self.failed = true
	end

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.room and not multiplayerModel.isPlaying then
		self:quit()
	end

	Navigator.update(self)
end

GameplayNavigator.keypressed = function(self, event)
	local state = self.game.rhythmModel.pauseManager.state

	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	local scancode = event[2]

	local input = self.game.configModel.configs.settings.input

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
	local state = self.game.rhythmModel.pauseManager.state
	local input = self.game.configModel.configs.settings.input

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
	self.game.gameplayController:saveCamera(x, y, z, pitch, yaw)
end

GameplayNavigator.skipIntro = function(self)
	self.game.timeController:skipIntro()
end

GameplayNavigator.increaseLocalOffset = function(self, delta)
	self.game.timeController:increaseLocalOffset(delta)
end

GameplayNavigator.increaseTimeRate = function(self, delta)
	self.game.timeController:increaseTimeRate(delta)
end

GameplayNavigator.invertTimeRate = function(self)
	self.game.timeController:invertTimeRate()
end

GameplayNavigator.increasePlaySpeed = function(self, delta)
	self.game.timeController:increasePlaySpeed(delta)
end

GameplayNavigator.invertPlaySpeed = function(self)
	self.game.timeController:invertPlaySpeed()
end

GameplayNavigator.play = function(self)
	self.game.gameplayController:receive({
		name = "playStateChange",
		state = "play"
	})
end

GameplayNavigator.pause = function(self)
	self.game.gameplayController:receive({
		name = "playStateChange",
		state = "pause"
	})
end

GameplayNavigator.retry = function(self)
	self.game.gameplayController:receive({
		name = "playStateChange",
		state = "retry"
	})
end

GameplayNavigator.forcePause = function(self)
	self.game.gameplayController:pause()
end

GameplayNavigator.forceRetry = function(self)
	self.failed = false
	self.game.gameplayController:retry()
end

GameplayNavigator.quit = function(self)
	local hasResult = self.game.gameplayController:hasResult()
	if hasResult then
		return self:changeScreen("resultView")
	end
	return self:changeScreen("selectView")
end

return GameplayNavigator
