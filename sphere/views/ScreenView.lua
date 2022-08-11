local Class = require("aqua.util.Class")
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

	local navigator = self.navigator
	local sequenceView = self.sequenceView

	navigator.screenView = self
	navigator.game = self.game
	navigator.viewConfig = assert(self.viewConfig)
	navigator.sequenceView = sequenceView

	sequenceView.game = self.game
	sequenceView.screenView = self
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
