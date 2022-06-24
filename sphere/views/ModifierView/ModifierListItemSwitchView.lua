local ListItemSwitchView = require("sphere.views.ListItemSwitchView")
local SwitchView = require("sphere.views.SwitchView")

local ModifierListItemSwitchView = ListItemSwitchView:new({construct = false})

ModifierListItemSwitchView.construct = function(self)
	ListItemSwitchView.construct(self)
	self.switchView = SwitchView:new()
end

ModifierListItemSwitchView.getName = function(self)
	return self.item.name
end

ModifierListItemSwitchView.getValue = function(self)
	return self.item.value
end

ModifierListItemSwitchView.setValue = function(self, value)
	self.listView.navigator:setModifierValue(self.item, value)
end

ModifierListItemSwitchView.mousepressed = function(self, event)
	local button = event[3]
	if button == 2 then
		self.listView.navigator:removeModifier(self.itemIndex)
	end
end

return ModifierListItemSwitchView
