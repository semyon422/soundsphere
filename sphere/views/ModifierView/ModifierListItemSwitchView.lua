local just = require("just")
local ListItemSwitchView = require("sphere.views.ListItemSwitchView")

local ModifierListItemSwitchView = ListItemSwitchView:new({construct = false})

ModifierListItemSwitchView.getName = function(self)
	return self.item.name
end

ModifierListItemSwitchView.getValue = function(self)
	return self.item.value
end

ModifierListItemSwitchView.setValue = function(self, value)
	self.listView.navigator:setModifierValue(self.item, value)
end

ModifierListItemSwitchView.draw = function(self, w, h)
	if just.button_behavior(tostring(self.item) .. "1", just.is_over(w, h), 2) then
		self.listView.navigator:removeModifier(self.itemIndex)
	end

	ListItemSwitchView.draw(self)
end

return ModifierListItemSwitchView
