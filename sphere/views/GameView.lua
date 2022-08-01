local Class = require("aqua.util.Class")
local FadeTransition = require("sphere.views.FadeTransition")
local FrameTimeView = require("sphere.views.FrameTimeView")
local TooltipView = require("sphere.views.TooltipView")

local GameView = Class:new()

GameView.construct = function(self)
	self.fadeTransition = FadeTransition:new()
	self.frameTimeView = FrameTimeView:new()
	self.tooltipView = TooltipView:new()
end

GameView.load = function(self)
	self.frameTimeView.game = self.game
	self.frameTimeView:load()
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
	self.tooltipView:draw()
	self.fadeTransition:drawAfter()
	self.frameTimeView:draw()
end

GameView.receive = function(self, event)
	if not self.view then
		return
	end
	self.view:receive(event)
	self.frameTimeView:receive(event)
end

return GameView
