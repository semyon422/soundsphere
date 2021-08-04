local viewspackage = (...):match("^(.-%.views%.)")

local ScreenView = require(viewspackage .. "ScreenView")

local ModifierViewConfig = require(viewspackage .. "ModifierView.ModifierViewConfig")
local ModifierNavigator = require(viewspackage .. "ModifierView.ModifierNavigator")
local AvailableModifierListView = require(viewspackage .. "ModifierView.AvailableModifierListView")
local ModifierListView = require(viewspackage .. "ModifierView.ModifierListView")

local ModifierView = ScreenView:new()

ModifierView.construct = function(self)
	self.viewConfig = ModifierViewConfig
	self.navigator = ModifierNavigator:new()
	self.availableModifierListView = AvailableModifierListView:new()
	self.modifierListView = ModifierListView:new()
end

ModifierView.load = function(self)
	local navigator = self.navigator
	local availableModifierListView = self.availableModifierListView
	local modifierListView = self.modifierListView

	local configModifier = self.configModel:getConfig("modifier")

	navigator.config = configModifier
	navigator.modifierModel = self.modifierModel

	availableModifierListView.navigator = navigator
	availableModifierListView.modifierModel = self.modifierModel

	modifierListView.navigator = navigator
	modifierListView.configModifier = configModifier
	modifierListView.modifierModel = self.modifierModel

	local sequenceView = self.sequenceView
	sequenceView:setView("AvailableModifierListView", availableModifierListView)
	sequenceView:setView("ModifierListView", modifierListView)

	ScreenView.load(self)
end

return ModifierView