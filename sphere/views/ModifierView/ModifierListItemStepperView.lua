local viewspackage = (...):match("^(.-%.views%.)")

local ListItemStepperView = require(viewspackage .. "ListItemStepperView")
local StepperView = require(viewspackage .. "StepperView")

local ModifierListItemStepperView = ListItemStepperView:new({construct = false})

ModifierListItemStepperView.construct = function(self)
	ListItemStepperView.construct(self)
	self.stepperView = StepperView:new()
end

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

ModifierListItemStepperView.mousepressed = function(self, event)
	local button = event[3]
	if button == 2 then
		self.listView.navigator:removeModifier(self.itemIndex)
	end
end

return ModifierListItemStepperView
