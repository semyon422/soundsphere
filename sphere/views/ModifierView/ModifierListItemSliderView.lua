local just = require("just")
local ListItemSliderView = require("sphere.views.ListItemSliderView")

local ModifierListItemSliderView = ListItemSliderView:new({construct = false})

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
	local modifier = self.listView.game.modifierModel:getModifier(self.item)
	return modifier:toNormValue(self.item.value)
end

ModifierListItemSliderView.updateNormValue = function(self, normValue)
	local modifier = self.listView.game.modifierModel:getModifier(self.item)
	self.listView.navigator:setModifierValue(
		self.item,
		modifier:fromNormValue(normValue)
	)
end

ModifierListItemSliderView.increaseValue = function(self, delta)
	self.listView.navigator:increaseModifierValue(self.itemIndex, delta)
end

ModifierListItemSliderView.draw = function(self, w, h)
	if just.button_behavior(tostring(self.item) .. "1", just.is_over(w, h), 2) then
		self.listView.navigator:removeModifier(self.itemIndex)
	end

	ListItemSliderView.draw(self)
end

return ModifierListItemSliderView
