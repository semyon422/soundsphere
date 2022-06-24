local ScreenView = require("sphere.views.ScreenView")

local SelectViewConfig = require("sphere.views.SelectView.SelectViewConfig")
local SelectNavigator = require("sphere.views.SelectView.SelectNavigator")
local SelectOverlayView = require("sphere.views.SelectView.SelectOverlayView")
local NoteSkinView = require("sphere.views.NoteSkinView")
local InputView = require("sphere.views.InputView")
local SettingsView = require("sphere.views.SettingsView")
local OnlineView = require("sphere.views.OnlineView")
local MountsView = require("sphere.views.MountsView")

local SelectView = ScreenView:new({construct = false})

SelectView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = SelectViewConfig
	self.navigator = SelectNavigator:new()

	self.noteSkinView = NoteSkinView:new()
	self.inputView = InputView:new()
	self.settingsView = SettingsView:new()
	self.onlineView = OnlineView:new()
	self.mountsView = MountsView:new()
	self.selectOverlayView = SelectOverlayView:new()
end

SelectView.load = function(self)
	self.game.selectController:load()
	ScreenView.load(self)

	self.noteSkinView.game = self.game
	self.noteSkinView.navigator = self.navigator
	self.noteSkinView.isOpen = self.navigator.isNoteSkinsOpen

	self.inputView.game = self.game
	self.inputView.navigator = self.navigator
	self.inputView.isOpen = self.navigator.isInputOpen

	self.settingsView.game = self.game
	self.settingsView.navigator = self.navigator
	self.settingsView.isOpen = self.navigator.isSettingsOpen

	self.onlineView.game = self.game
	self.onlineView.navigator = self.navigator
	self.onlineView.isOpen = self.navigator.isOnlineOpen

	self.mountsView.game = self.game
	self.mountsView.navigator = self.navigator
	self.mountsView.isOpen = self.navigator.isMountsOpen

	self.selectOverlayView.game = self.game
	self.selectOverlayView.navigator = self.navigator
end

SelectView.draw = function(self)
	ScreenView.draw(self)
	self.noteSkinView:draw()
	self.inputView:draw()
	self.settingsView:draw()
	self.onlineView:draw()
	self.mountsView:draw()
	self.selectOverlayView:draw()
end

SelectView.unload = function(self)
	self.game.selectController:unload()
	ScreenView.unload(self)
end

SelectView.update = function(self, dt)
	self.game.selectController:update(dt)
	ScreenView.update(self, dt)
end

return SelectView
