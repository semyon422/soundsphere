local viewspackage = (...):match("^(.-%.views%.)")

local ListItemStepperView = require(viewspackage .. "ListItemStepperView")
local StepperView = require(viewspackage .. "StepperView")

local SettingsListItemStepperView = ListItemStepperView:new()

SettingsListItemStepperView.construct = function(self)
	self.stepperView = StepperView:new()
end

SettingsListItemStepperView.getName = function(self)
	return self.item.name
end

SettingsListItemStepperView.getValue = function(self)
	local value = self.listView.settingsModel:getValue(self.item)
	return self.item.displayValues[value]
end

SettingsListItemStepperView.getIndexValue = function(self)
	return self.item.value
end

SettingsListItemStepperView.getCount = function(self)
	return #self.item.displayValues
end

SettingsListItemStepperView.updateIndexValue = function(self, indexValue)
	-- local modifier = self.listView.modifierModel:getModifier(self.item)
	-- self.listView.navigator:setModifierValue(
	-- 	self.item,
	-- 	modifier:fromIndexValue(indexValue)
	-- )
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
