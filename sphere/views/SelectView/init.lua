local ScreenView = require("sphere.views.ScreenView")

local SelectViewConfig = require("sphere.views.SelectView.SelectViewConfig")
local SelectNavigator = require("sphere.views.SelectView.SelectNavigator")
local NoteSkinView = require("sphere.views.NoteSkinView")
local InputView = require("sphere.views.InputView")
local SettingsView = require("sphere.views.SettingsView")
local OnlineView = require("sphere.views.OnlineView")
local MountsView = require("sphere.views.MountsView")
local ModifierView = require("sphere.views.ModifierView")

local SelectView = ScreenView:new({construct = false})

SelectView.subscreen = "notecharts"
SelectView.searchMode = "filter"

SelectView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = SelectViewConfig
	self.navigator = SelectNavigator:new()

	self.noteSkinView = NoteSkinView:new()
	self.inputView = InputView:new()
	self.settingsView = SettingsView:new()
	self.onlineView = OnlineView:new()
	self.mountsView = MountsView:new()
	self.modifierView = ModifierView:new()
end

SelectView.load = function(self)
	self.game.selectController:load()
	ScreenView.load(self)

	self.noteSkinView.game = self.game
	self.inputView.game = self.game
	self.settingsView.game = self.game
	self.onlineView.game = self.game
	self.mountsView.game = self.game
	self.modifierView.game = self.game
	self.modifierView.screenView = self
	self.modifierView:load()
end

SelectView.draw = function(self)
	ScreenView.draw(self)
	self.noteSkinView:draw()
	self.inputView:draw()
	self.settingsView:draw()
	self.onlineView:draw()
	self.mountsView:draw()
	self.modifierView:draw()
end

SelectView.unload = function(self)
	self.game.selectController:unload()
	self.modifierView:unload()
	ScreenView.unload(self)
end

SelectView.update = function(self, dt)
	self.game.selectController:update(dt)
	self.modifierView:update(dt)

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.room and multiplayerModel.isPlaying then
		self:play()
	end

	ScreenView.update(self, dt)
end

SelectNavigator.play = function(self)
	if self.game.selectModel:notechartExists() then
		self:changeScreen("gameplayView")
	end
end

SelectNavigator.result = function(self)
	if self.game.selectModel:isPlayed() then
		self:changeScreen("resultView")
	end
end

SelectView.switchToNoteCharts = function(self)
	self.subscreen = "notecharts"
	self.searchMode = "filter"
	self.game.selectModel:noDebouncePullNoteChartSet()
end

SelectView.switchToCollections = function(self)
	self.subscreen = "collections"
end

SelectView.switchToOsudirect = function(self)
	self.searchMode = "osudirect"
	self.subscreen = "osudirect"
	self.game.osudirectModel:searchNoDebounce()
end

SelectView.setSearchMode = function(self, searchMode)
	self.searchMode = searchMode
end

SelectView.changeSearchMode = function(self)
	if self.searchMode == "filter" then
		self:setSearchMode("lamp")
	else
		self:setSearchMode("filter")
	end
end

return SelectView
