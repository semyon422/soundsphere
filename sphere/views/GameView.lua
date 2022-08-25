local just = require("just")
local Class = require("aqua.util.Class")
local FadeTransition = require("sphere.views.FadeTransition")
local FrameTimeView = require("sphere.views.FrameTimeView")
local TextTooltipImView = require("sphere.imviews.TextTooltipImView")
local ContextMenuImView = require("sphere.imviews.ContextMenuImView")
local ModalImView = require("sphere.imviews.ModalImView")
local NoteSkinView = require("sphere.views.NoteSkinView")
local InputView = require("sphere.views.InputView")
local SettingsView = require("sphere.views.SettingsView")
local OnlineView = require("sphere.views.OnlineView")
local MountsView = require("sphere.views.MountsView")
local ModifierView = require("sphere.views.ModifierView")
local LobbyView = require("sphere.views.LobbyView")

local GameView = Class:new()

GameView.construct = function(self)
	self.fadeTransition = FadeTransition:new()
	self.frameTimeView = FrameTimeView:new()

	self.noteSkinView = NoteSkinView:new()
	self.inputView = InputView:new()
	self.settingsView = SettingsView:new()
	self.onlineView = OnlineView:new()
	self.mountsView = MountsView:new()
	self.modifierView = ModifierView:new()
	self.lobbyView = LobbyView:new()
end

GameView.load = function(self)
	self.noteSkinView.game = self.game
	self.inputView.game = self.game
	self.settingsView.game = self.game
	self.onlineView.game = self.game
	self.mountsView.game = self.game
	self.modifierView.game = self.game
	self.lobbyView.game = self.game

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

	self.noteSkinView:draw()
	self.inputView:draw()
	self.settingsView:draw()
	self.onlineView:draw()
	self.mountsView:draw()
	self.modifierView:draw()
	self.lobbyView:draw()

	if ModalImView(self.modal, self) then
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
	self.modal = f
end

GameView.hideAllWindows = function(self)
	self.noteSkinView:toggle(false)
	self.inputView:toggle(false)
	self.settingsView:toggle(false)
	self.onlineView:toggle(false)
	self.mountsView:toggle(false)
	self.modifierView:toggle(false)
	self.lobbyView:toggle(false)
end

return GameView
