local viewspackage = (...):match("^(.-%.views%.)")

local ListItemSwitchView = require(viewspackage .. "ListItemSwitchView")
local SwitchView = require(viewspackage .. "SwitchView")

local SettingsListItemSwitchView = ListItemSwitchView:new()

SettingsListItemSwitchView.construct = function(self)
	self.switchView = SwitchView:new()
end

SettingsListItemSwitchView.getName = function(self)
	return self.item.name
end

SettingsListItemSwitchView.getValue = function(self)
	return self.listView.settingsModel:getValue(self.item)
end

SettingsListItemSwitchView.increaseValue = function(self, delta)
	self.listView.navigator:increaseSettingValue(self.itemIndex, delta)
end

SettingsListItemSwitchView.mousepressed = function(self, event)
	local button = event.args[3]
	if button == 2 then
		self.listView.navigator:resetSetting(self.itemIndex)
	end
end

return SettingsListItemSwitchView
