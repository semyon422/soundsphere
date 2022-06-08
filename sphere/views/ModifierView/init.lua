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
	self.controller = self.game.modifierController
	self.game.modifierController:load()
	self:loadViews(ScreenView.views)
	self:loadViews(self.views)
	ScreenView.load(self)
end

ModifierView.unload = function(self)
	self.game.modifierController:unload()
	ScreenView.unload(self)
end

ModifierView.update = function(self, dt)
	self.game.modifierController:update(dt)
	ScreenView.update(self, dt)
end

ModifierView.receive = function(self, event)
	self.game.modifierController:receive(event)
	ScreenView.receive(self, event)
end

return ModifierView
