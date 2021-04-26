local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")
local SettingsNavigator = require(viewspackage .. "SettingsView.SettingsNavigator")
local SettingsListView = require(viewspackage .. "SettingsView.SettingsListView")
local SectionsListView = require(viewspackage .. "SettingsView.SectionsListView")
local BackgroundView = require(viewspackage .. "BackgroundView")

local SettingsView = Class:new()

SettingsView.construct = function(self)
	self.node = Node:new()
end

SettingsView.load = function(self)
	local node = self.node
	local config = self.configModel:getConfig("settings")

	local navigator = SettingsNavigator:new()
	self.navigator = navigator
	navigator.config = config
	navigator.view = self

	local sectionsListView = SectionsListView:new()
	sectionsListView.navigator = navigator
	sectionsListView.config = config
	sectionsListView.view = self

	local settingsListView = SettingsListView:new()
	settingsListView.navigator = navigator
	settingsListView.config = config
	settingsListView.view = self

	local backgroundView = BackgroundView:new()
	backgroundView.view = self

	node:node(backgroundView)
	node:node(sectionsListView)
	node:node(settingsListView)

	navigator:load()
end

SettingsView.unload = function(self)
	self.navigator:unload()
end

SettingsView.receive = function(self, event)
	self.navigator:receive(event)
	self.node:callnext(event.name, event)
end

SettingsView.update = function(self, dt)
	self.node:callnext("update")
	self.navigator:update()
end

SettingsView.draw = function(self)
	self.node:callnext("draw")
end

return SettingsView
