local Class = require("aqua.util.Class")
local SequenceView = require("sphere.views.SequenceView")

local ScreenView = Class:new()

ScreenView.construct = function(self)
	self.sequenceView = SequenceView:new()
end

ScreenView.changeScreen = function(self, screenName, noTransition)
	self.gameView:setView(self.game[screenName], noTransition)
end

ScreenView.load = function(self)
	local navigator = self.navigator
	local sequenceView = self.sequenceView

	navigator.view = self
	navigator.game = self.game
	navigator.viewConfig = assert(self.viewConfig)
	navigator.sequenceView = sequenceView

	sequenceView.game = self.game
	sequenceView.navigator = navigator
	sequenceView:setSequenceConfig(self.viewConfig)
	sequenceView:load()

	navigator:load()
end

ScreenView.unload = function(self)
	self.sequenceView:unload()
	self.navigator:unload()
end

ScreenView.receive = function(self, event)
	self.navigator:receive(event)
	self.sequenceView:receive(event)
end

ScreenView.update = function(self, dt)
	self.navigator:update()
	self.sequenceView:update(dt)
end

ScreenView.draw = function(self)
	self.sequenceView:draw()
end

return ScreenView
