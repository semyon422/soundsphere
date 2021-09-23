local viewspackage = (...):match("^(.-%.views%.)")

local ListItemStepperView = require(viewspackage .. "ListItemStepperView")
local StepperView = require(viewspackage .. "StepperView")

local SettingsListItemStepperView = ListItemStepperView:new({construct = false})

SettingsListItemStepperView.construct = function(self)
	ListItemStepperView.construct(self)
	self.stepperView = StepperView:new()
end

SettingsListItemStepperView.getName = function(self)
	return self.item.name
end

SettingsListItemStepperView.getValue = function(self)
	return self.listView.gameController.settingsModel:getValue(self.item)
end

SettingsListItemStepperView.getDisplayValue = function(self)
	return self.listView.gameController.settingsModel:getDisplayValue(self.item)
end

SettingsListItemStepperView.getIndexValue = function(self)
	return self.listView.gameController.settingsModel:toIndexValue(self.item)
end

SettingsListItemStepperView.getCount = function(self)
	return self.listView.gameController.settingsModel:getCount(self.item)
end

SettingsListItemStepperView.updateIndexValue = function(self, indexValue)
	local value = self.listView.gameController.settingsModel:fromIndexValue(self.item, indexValue)
	self.listView.navigator:setSettingValue(self.itemIndex, value)
end

SettingsListItemStepperView.increaseValue = function(self, delta)
	self.listView.navigator:increaseSettingValue(self.itemIndex, delta)
end

SettingsListItemStepperView.mousepressed = function(self, event)
	local button = event.args[3]
	if button == 2 then
		self.listView.navigator:resetSetting(self.itemIndex)
	end
end

return SettingsListItemStepperView
