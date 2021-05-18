local viewspackage = (...):match("^(.-%.views%.)")

local ListItemSliderView = require(viewspackage .. "ListItemSliderView")
local SliderView = require(viewspackage .. "SliderView")

local ModifierListItemSliderView = ListItemSliderView:new()

ModifierListItemSliderView.construct = function(self)
	self.sliderView = SliderView:new()
end

ModifierListItemSliderView.getName = function(self)
	return self.item.name
end

ModifierListItemSliderView.getValue = function(self)
	return self.item.value
end

ModifierListItemSliderView.getDisplayValue = function(self)
	return self.item.value
end

ModifierListItemSliderView.getNormValue = function(self)
	local modifier = self.listView.modifierModel:getModifier(self.item)
	return modifier:toNormValue(self.item.value)
end

ModifierListItemSliderView.updateNormValue = function(self, normValue)
	local modifier = self.listView.modifierModel:getModifier(self.item)
	self.listView.navigator:setModifierValue(
		self.item,
		modifier:fromNormValue(normValue)
	)
end

ModifierListItemSliderView.increaseValue = function(self, delta)
	self.listView.navigator:increaseModifierValue(self.itemIndex, delta)
end

ModifierListItemSliderView.mousepressed = function(self, event)
	local button = event.args[3]
	if button == 2 then
		self.listView.navigator:removeModifier(self.itemIndex)
	end
end

return ModifierListItemSliderView
