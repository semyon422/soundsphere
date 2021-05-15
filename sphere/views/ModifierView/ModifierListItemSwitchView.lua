local viewspackage = (...):match("^(.-%.views%.)")

local ListItemSwitchView = require(viewspackage .. "ListItemSwitchView")
local SwitchView = require(viewspackage .. "SwitchView")

local ModifierListItemSwitchView = ListItemSwitchView:new()

ModifierListItemSwitchView.construct = function(self)
	self.switchView = SwitchView:new()
end

ModifierListItemSwitchView.getName = function(self)
	return self.item.name
end

ModifierListItemSwitchView.getValue = function(self)
	return self.item.value
end

ModifierListItemSwitchView.increaseValue = function(self, delta)
	self.listView.navigator:increaseModifierValue(self.itemIndex, delta)
end

ModifierListItemSwitchView.mousepressed = function(self, event)
	local button = event.args[3]
	if button == 2 then
		self.listView.navigator:removeModifier(self.itemIndex)
	end
end

return ModifierListItemSwitchView
