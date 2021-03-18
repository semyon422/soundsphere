local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")
local SettingsNavigator = require(viewspackage .. "SettingsView.SettingsNavigator")
local SettingsListView = require(viewspackage .. "SettingsView.SettingsListView")
local CategoriesListView = require(viewspackage .. "SettingsView.CategoriesListView")
local BackgroundView = require(viewspackage .. "BackgroundView")

local SettingsView = Class:new()

SettingsView.construct = function(self)
	self.node = Node:new()
end

SettingsView.load = function(self)
	local node = self.node
	local config_settings = self.configModel:getConfig("settings")
	local config_settings_model = self.configModel:getConfig("settings_model")

	local navigator = SettingsNavigator:new()
	self.navigator = navigator
	navigator.config_settings = config_settings
	navigator.config_settings_model = config_settings_model
	navigator.view = self

	local categoriesListView = CategoriesListView:new()
	categoriesListView.navigator = navigator
	categoriesListView.config_settings = config_settings
	categoriesListView.config_settings_model = config_settings_model
	categoriesListView.view = self

	local settingsListView = SettingsListView:new()
	settingsListView.navigator = navigator
	settingsListView.config_settings = config_settings
	settingsListView.config_settings_model = config_settings_model
	settingsListView.view = self

	local backgroundView = BackgroundView:new()
	backgroundView.view = self

	node:node(backgroundView)
	node:node(categoriesListView)
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
