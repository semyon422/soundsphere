local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local ModifierViewConfig = require(viewspackage .. "ModifierView.ModifierViewConfig")
local ModifierNavigator = require(viewspackage .. "ModifierView.ModifierNavigator")
local AvailableModifierListView = require(viewspackage .. "ModifierView.AvailableModifierListView")
local ModifierListView = require(viewspackage .. "ModifierView.ModifierListView")

local ModifierView = ScreenView:new({construct = false})

ModifierView.views = {
	{"availableModifierListView", AvailableModifierListView, "AvailableModifierListView"},
	{"modifierListView", ModifierListView, "ModifierListView"},
}

ModifierView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = ModifierViewConfig
	self.navigator = ModifierNavigator:new()
	self:createViews(ScreenView.views)
	self:createViews(self.views)
end

ModifierView.load = function(self)
	self:loadViews(ScreenView.views)
	self:loadViews(self.views)
	ScreenView.load(self)
end

return ModifierView
