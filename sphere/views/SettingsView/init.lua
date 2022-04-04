local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local SettingsViewConfig = require(viewspackage .. "SettingsView.SettingsViewConfig")
local SettingsNavigator = require(viewspackage .. "SettingsView.SettingsNavigator")
local SettingsListView = require(viewspackage .. "SettingsView.SettingsListView")
local SectionsListView = require(viewspackage .. "SettingsView.SectionsListView")

local SettingsView = ScreenView:new({construct = false})

SettingsView.views = {
	{"sectionsListView", SectionsListView, "SectionsListView"},
	{"settingsListView", SettingsListView, "SettingsListView"},
}

SettingsView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = SettingsViewConfig
	self.navigator = SettingsNavigator:new()
	self:createViews(ScreenView.views)
	self:createViews(self.views)
end

SettingsView.load = function(self)
	self:loadViews(ScreenView.views)
	self:loadViews(self.views)
	ScreenView.load(self)
end

return SettingsView
