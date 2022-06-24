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
	ScreenView.load(self)
end

GameplayView.unload = function(self)
	self.game.gameplayController:unload()
	self.game.rhythmModel.observable:remove(self.sequenceView)
	ScreenView.unload(self)
	self.viewConfig[self.playfieldViewConfigIndex] = self.playfieldViewConfig
end

GameplayView.update = function(self, dt)
	self.game.gameplayController:update(dt)
	ScreenView.update(self, dt)
end

GameplayView.receive = function(self, event)
	self.game.gameplayController:receive(event)
	ScreenView.receive(self, event)
end

return GameplayView
