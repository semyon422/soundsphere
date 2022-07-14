local just = require("just")
local ListItemStepperView = require("sphere.views.ListItemStepperView")

local ModifierListItemStepperView = ListItemStepperView:new({construct = false})

ModifierListItemStepperView.getName = function(self)
	return self.item.name
end

ModifierListItemStepperView.getValue = function(self)
	return self.item.value
end

ModifierListItemStepperView.getDisplayValue = function(self)
	return self.item.value
end

ModifierListItemStepperView.getIndexValue = function(self)
	local modifier = self.listView.game.modifierModel:getModifier(self.item)
	return modifier:toIndexValue(self.item.value)
end

ModifierListItemStepperView.getCount = function(self)
	local modifier = self.listView.game.modifierModel:getModifier(self.item)
	return modifier:getCount()
end

ModifierListItemStepperView.updateIndexValue = function(self, indexValue)
	local modifier = self.listView.game.modifierModel:getModifier(self.item)
	self.listView.navigator:setModifierValue(
		self.item,
		modifier:fromIndexValue(indexValue)
	)
end

ModifierListItemStepperView.increaseValue = function(self, delta)
	self.listView.navigator:increaseModifierValue(self.itemIndex, delta)
end

ModifierListItemStepperView.draw = function(self, w, h)
	if just.button_behavior(tostring(self.item) .. "1", just.is_over(w, h), 2) then
		self.listView.navigator:removeModifier(self.itemIndex)
	end

	ListItemStepperView.draw(self)
end

return ModifierListItemStepperView
