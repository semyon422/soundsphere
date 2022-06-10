local Class = require("aqua.util.Class")
local FadeTransition = require("sphere.views.FadeTransition")

local GameView = Class:new()

GameView.construct = function(self)
	self.fadeTransition = FadeTransition:new()
end

GameView.load = function(self)
	self:setView(self.game.selectView)
end

GameView._setView = function(self, view)
	if self.view then
		self.view:unload()
	end
	view.prevView = self.view
	self.view = view
	self.view:load()
end

GameView.setView = function(self, view, noTransition)
	view.gameView = self
	if noTransition then
		return self:_setView(view)
	end
	self.fadeTransition:transitIn(function()
		self:_setView(view)
		self.fadeTransition:transitOut()
	end)
end

GameView.unload = function(self)
	if not self.view then
		return
	end
	self.view:unload()
end

GameView.update = function(self, dt)
	self.fadeTransition:update(dt)
	if not self.view then
		return
	end
	self.view:update(dt)
end

GameView.draw = function(self)
	if not self.view then
		return
	end
	self.fadeTransition:drawBefore()
	self.view:draw()
	self.fadeTransition:drawAfter()
end

GameView.receive = function(self, event)
	if not self.view then
		return
	end
	self.view:receive(event)
end

return GameView
