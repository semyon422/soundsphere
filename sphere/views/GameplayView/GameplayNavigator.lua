local Navigator = require("sphere.views.Navigator")

local GameplayNavigator = Navigator:new({construct = false})

GameplayNavigator.state = "play"

GameplayNavigator.load = function(self)
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
		self.game.gameplayController:pause()
	end
end

GameplayNavigator.keypressed = function(self, event)
	local state = self.game.rhythmModel.pauseManager.state

	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
	local s = event[2]

	local input = self.game.configModel.configs.settings.input
	local timeController = self.game.timeController

	if s == input.skipIntro then self.game.timeController:skipIntro()
	elseif s == input.offset.decrease then timeController:increaseLocalOffset(-0.001)
	elseif s == input.offset.increase then timeController:increaseLocalOffset(0.001)
	elseif s == input.timeRate.decrease then timeController:increaseTimeRate(-0.05)
	elseif s == input.timeRate.increase then timeController:increaseTimeRate(0.05)
	-- elseif scancode == input.timeRate.invert then timeController:invertTimeRate()
	elseif s == input.playSpeed.decrease then timeController:increasePlaySpeed(-0.05)
	elseif s == input.playSpeed.increase then timeController:increasePlaySpeed(0.05)
	elseif s == input.playSpeed.invert then timeController:invertPlaySpeed()
	end

	local gameplayController = self.game.gameplayController

	if state == "play" then
		if s == input.pause and not shift then gameplayController:changePlayState("pause")
		elseif s == input.pause and shift then self.screenView:quit()
		elseif s == input.quickRestart then gameplayController:changePlayState("retry")
		end
	elseif state == "pause" then
		if s == input.pause and not shift then gameplayController:changePlayState("play")
		elseif s == input.pause and shift then self.screenView:quit()
		elseif s == input.quickRestart then gameplayController:changePlayState("retry")
		end
	elseif state == "pause-play" and s == input.pause then
		self.game.gameplayController:changePlayState("pause")
	end
end

GameplayNavigator.keyreleased = function(self, event)
	local state = self.game.rhythmModel.pauseManager.state
	local input = self.game.configModel.configs.settings.input
	local gameplayController = self.game.gameplayController

	local s = event[2]
	if state == "play-pause" and s == input.pause then
		gameplayController:changePlayState("play")
	elseif state == "pause-retry" and s == input.quickRestart then
		gameplayController:changePlayState("pause")
	elseif state == "play-retry" and s == input.quickRestart then
		gameplayController:changePlayState("play")
	end
end

return GameplayNavigator
