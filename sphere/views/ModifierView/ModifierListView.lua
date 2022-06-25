local ListView = require("sphere.views.ListView")
local ModifierListItemSwitchView = require("sphere.views.ModifierView.ModifierListItemSwitchView")
local ModifierListItemSliderView = require("sphere.views.ModifierView.ModifierListItemSliderView")
local ModifierListItemStepperView = require("sphere.views.ModifierView.ModifierListItemStepperView")

local ModifierListView = ListView:new({construct = false})

ModifierListView.construct = function(self)
	ListView.construct(self)

	self.itemSwitchView = ModifierListItemSwitchView:new()
	self.itemSliderView = ModifierListItemSliderView:new()
	self.itemStepperView = ModifierListItemStepperView:new()
	self.itemSwitchView.listView = self
	self.itemSliderView.listView = self
	self.itemStepperView.listView = self
end

ModifierListView.getItemView = function(self, modifierConfig)
	local modifier = self.game.modifierModel:getModifier(modifierConfig)
	if modifier.interfaceType == "toggle" then
		return self.itemSwitchView
	elseif modifier.interfaceType == "slider" then
		return self.itemSliderView
	elseif modifier.interfaceType == "stepper" then
		return self.itemStepperView
	end
end

ModifierListView.reloadItems = function(self)
	self.items = self.game.modifierModel.config
end

ModifierListView.getItemIndex = function(self)
	return self.game.modifierModel.modifierItemIndex
end

ModifierListView.scrollUp = function(self)
	self.navigator:scrollModifier("up")
end

ModifierListView.scrollDown = function(self)
	self.navigator:scrollModifier("down")
end

return ModifierListView
