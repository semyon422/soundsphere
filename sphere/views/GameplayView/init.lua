local GameplayViewConfig = require("sphere.views.GameplayView.GameplayViewConfig")
local GameplayNavigator	= require("sphere.views.GameplayView.GameplayNavigator")
local ScreenView = require("sphere.views.ScreenView")

local GameplayView = ScreenView:new({construct = false})

GameplayView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = GameplayViewConfig
	self.navigator = GameplayNavigator:new()
end

GameplayView.load = function(self)
	self.game.rhythmModel.observable:add(self.sequenceView)
	self.game.gameplayController:load()

	local noteSkin = self.game.rhythmModel.graphicEngine.noteSkin
	for i, config in ipairs(self.viewConfig) do
		if config.class == "PlayfieldView" then
			self.playfieldViewConfig = self.viewConfig[i]
			self.playfieldViewConfigIndex = i
			self.viewConfig[i] = noteSkin.playField
		end
	end

	self.subscreen = ""
	self.failed = false
	ScreenView.load(self)
end

GameplayView.unload = function(self)
	self.game.gameplayController:unload()
	self.game.rhythmModel.observable:remove(self.sequenceView)
	ScreenView.unload(self)
	self.viewConfig[self.playfieldViewConfigIndex] = self.playfieldViewConfig
end

GameplayView.retry = function(self)
	self.game.gameplayController:retry()
	self.sequenceView:unload()
	self.sequenceView:load()
end

GameplayView.update = function(self, dt)
	self.game.gameplayController:update(dt)

	local state = self.game.rhythmModel.pauseManager.state
	if state == "play" then
		self.subscreen = ""
	elseif state == "pause" then
		self.subscreen = "pause"
	end

	if self.game.rhythmModel.pauseManager.needRetry then
		self.failed = false
		self:retry()
	end

	local timeEngine = self.game.rhythmModel.timeEngine
	if timeEngine.currentTime >= timeEngine.maxTime + 1 then
		self:quit()
	end

	local actionOnFail = self.game.configModel.configs.settings.gameplay.actionOnFail
	local failed = self.game.rhythmModel.scoreEngine.scoreSystem.hp.failed
	if failed and not self.failed then
		if actionOnFail == "pause" then
			self.game.gameplayController:changePlayState("pause")
			self.failed = true
		elseif actionOnFail == "quit" then
			self:quit()
		end
	end

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.room and not multiplayerModel.isPlaying then
		self:quit()
	end

	ScreenView.update(self, dt)
end

GameplayView.receive = function(self, event)
	self.game.gameplayController:receive(event)
	ScreenView.receive(self, event)
end

GameplayView.quit = function(self)
	if self.game.gameplayController:hasResult() then
		return self:changeScreen("resultView")
	elseif self.game.multiplayerModel.room then
		return self:changeScreen("multiplayerView")
	end
	return self:changeScreen("selectView")
end

return GameplayView
