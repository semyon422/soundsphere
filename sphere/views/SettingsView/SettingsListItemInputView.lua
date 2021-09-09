local viewspackage = (...):match("^(.-%.views%.)")

local ListItemInputView = require(viewspackage .. "ListItemInputView")
local SwitchView = require(viewspackage .. "SwitchView")

local SettingsListItemInputView = ListItemInputView:new({construct = false})

SettingsListItemInputView.construct = function(self)
	ListItemInputView.construct(self)
	self.switchView = SwitchView:new()
end

SettingsListItemInputView.getName = function(self)
	return self.item.name
end

SettingsListItemInputView.getValue = function(self)
	return self.listView.settingsModel:getValue(self.item)
end

SettingsListItemInputView.isActive = function(self)
	local navigator = self.listView.navigator
	return navigator.activeElement == "inputHandler" and navigator.inputItemIndex == self.itemIndex
end

SettingsListItemInputView.mousepressed = function(self, event)
	local button = event.args[3]
	if button == 2 then
		self.listView.navigator:resetSetting(self.itemIndex)
	end
	if button == 1 then
		self.listView.navigator:setInputHandler(self.itemIndex)
	end
end

return SettingsListItemInputView
