local viewspackage = (...):match("^(.-%.views%.)")

local CoordinateManager = require("aqua.graphics.CoordinateManager")
local ListView = require(viewspackage .. "ListView")
local ModifierListItemSwitchView = require(viewspackage .. "ModifierView.ModifierListItemSwitchView")
local ModifierListItemSliderView = require(viewspackage .. "ModifierView.ModifierListItemSliderView")
local ModifierListItemStepperView = require(viewspackage .. "ModifierView.ModifierListItemStepperView")
local Slider = require(viewspackage .. "Slider")
local Switch = require(viewspackage .. "Switch")
local Stepper = require(viewspackage .. "Stepper")

local ModifierListView = ListView:new()

ModifierListView.construct = function(self)
	ListView.construct(self)
	self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")

	self.itemSwitchView = ModifierListItemSwitchView:new()
	self.itemSliderView = ModifierListItemSliderView:new()
	self.itemStepperView = ModifierListItemStepperView:new()
	self.itemSwitchView.listView = self
	self.itemSliderView.listView = self
	self.itemStepperView.listView = self

	self.slider = Slider:new()
	self.switch = Switch:new()
	self.stepper = Stepper:new()
end

ModifierListView.load = function(self)
	ListView.load(self)
	self.state.activeItem = self.state.selectedItem
end

ModifierListView.getItemView = function(self, modifierConfig)
	local modifier = self.view.modifierModel:getModifier(modifierConfig)
	if modifier.interfaceType == "toggle" then
		return self.itemSwitchView
	elseif modifier.interfaceType == "slider" then
		return self.itemSliderView
	elseif modifier.interfaceType == "stepper" then
		return self.itemStepperView
	end
end

ModifierListView.reloadItems = function(self)
	self.items = self.view.configModel:getConfig("modifier")
end

ModifierListView.forceScroll = function(self)
	self.state.selectedItem = self.modifierModel.modifierItemIndex
	self.state.selectedVisualItem = self.modifierModel.modifierItemIndex
end

ModifierListView.getItemIndex = function(self)
	return self.modifierModel.modifierItemIndex
end

ModifierListView.scrollUp = function(self)
	self.navigator:scrollModifier("up")
end

ModifierListView.scrollDown = function(self)
	self.navigator:scrollModifier("down")
end

return ModifierListView
