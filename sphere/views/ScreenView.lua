local Class = require("Class")
local SequenceView = require("sphere.views.SequenceView")

local ScreenView = Class:new()

ScreenView.construct = function(self)
	self.sequenceView = SequenceView:new()
end

ScreenView.changeScreen = function(self, screenName, noTransition)
	self.isChangingScreen = true
	self.gameView:setView(self.game[screenName], noTransition)
end

ScreenView.load = function(self)
	self.isChangingScreen = false

	local sequenceView = self.sequenceView

	sequenceView.game = self.game
	sequenceView.screenView = self
	sequenceView:setSequenceConfig(self.viewConfig)
	sequenceView:load()
end

ScreenView.unload = function(self)
	self.sequenceView:unload()
end

ScreenView.receive = function(self, event)
	self.sequenceView:receive(event)
end

ScreenView.update = function(self, dt)
	self.sequenceView:update(dt)
end

ScreenView.draw = function(self)
	self.sequenceView:draw()
end

return ScreenView
