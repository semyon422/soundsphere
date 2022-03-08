local viewspackage = (...):match("^(.-%.views%.)")

local ListItemSwitchView = require(viewspackage .. "ListItemSwitchView")
local SwitchView = require(viewspackage .. "SwitchView")

local SettingsListItemSwitchView = ListItemSwitchView:new({construct = false})

SettingsListItemSwitchView.construct = function(self)
	ListItemSwitchView.construct(self)
	self.switchView = SwitchView:new()
end

SettingsListItemSwitchView.getName = function(self)
	return self.item.name
end

SettingsListItemSwitchView.getValue = function(self)
	return self.listView.gameController.settingsModel:getValue(self.item)
end

SettingsListItemSwitchView.setValue = function(self, value)
	self.listView.navigator:setSettingValue(self.itemIndex, value)
end

SettingsListItemSwitchView.mousepressed = function(self, event)
	local button = event[3]
	if button == 2 then
		self.listView.navigator:resetSetting(self.itemIndex)
	end
end

return SettingsListItemSwitchView
