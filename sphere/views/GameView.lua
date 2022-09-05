local just = require("just")
local Class = require("aqua.util.Class")
local FadeTransition = require("sphere.views.FadeTransition")
local FrameTimeView = require("sphere.views.FrameTimeView")
local TextTooltipImView = require("sphere.imviews.TextTooltipImView")
local ContextMenuImView = require("sphere.imviews.ContextMenuImView")
local OnlineView = require("sphere.views.OnlineView")
local ModifierView = require("sphere.views.ModifierView")

local GameView = Class:new()

GameView.construct = function(self)
	self.fadeTransition = FadeTransition:new()
	self.frameTimeView = FrameTimeView:new()

	self.onlineView = OnlineView:new()
	self.modifierView = ModifierView:new()
end

GameView.load = function(self)
	self.onlineView.game = self.game
	self.modifierView.game = self.game

	self.frameTimeView.game = self.game

	self.frameTimeView:load()
	self.modifierView:load()

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
	self.modifierView:unload()
end

GameView.update = function(self, dt)
	self.fadeTransition:update(dt)
	if not self.view then
		return
	end
	self.view:update(dt)
	self.modifierView:update(dt)
end

GameView.draw = function(self)
	if not self.view then
		return
	end
	self.fadeTransition:drawBefore()
	self.view:draw()

	self.onlineView:draw()
	self.modifierView:draw()

	if self.modal and self.modal(self) then
		self.modal = nil
	end
	if self.contextMenu and ContextMenuImView(self.contextMenuWidth) then
		if ContextMenuImView(self.contextMenu()) then
			self.contextMenu = nil
		end
	end
	if self.tooltip then
		TextTooltipImView(self.tooltip)
		self.tooltip = nil
	end

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

GameView.setContextMenu = function(self, f, width)
	self.contextMenu = f
	self.contextMenuWidth = width
end

GameView.setModal = function(self, f)
	local _f = self.modal
	if not _f then
		self.modal = f
		return
	end
	if not _f() then
		return
	end
	self.modal = f
	if _f == f then
		self.modal = nil
	end
end

GameView.hideAllWindows = function(self)
	self.onlineView:toggle(false)
	self.modifierView:toggle(false)
end

return GameView
