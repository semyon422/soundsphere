local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local SettingsNavigator = Navigator:new({construct = false})

SettingsNavigator.construct = function(self)
	Navigator.construct(self)

	self.activeElement = "sections"
	self.sectionItemIndex = 1
	self.settingItemIndex = 1
	self.inputItemIndex = 1
end

SettingsNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event.args[2]
	if self.activeElement == "settings" then
		if scancode == "up" then self:scrollSettings("up")
		elseif scancode == "down" then self:scrollSettings("down")
		elseif scancode == "return" then self:setInputHandler()
		elseif scancode == "backspace" then self:resetSetting()
		elseif scancode == "right" then self:increaseSettingValue(nil, 1)
		elseif scancode == "left" then self:increaseSettingValue(nil, -1)
		elseif scancode == "escape" then self.activeElement = "sections"
		end
	elseif self.activeElement == "sections" then
		if scancode == "up" then self:scrollSections("up")
		elseif scancode == "down" then self:scrollSections("down")
		elseif scancode == "return" then self.activeElement = "settings"
		elseif scancode == "escape" then self:changeScreen("Select")
		end
	elseif self.activeElement == "inputHandler" then
		self:setInputBinding(scancode)
	end
end

SettingsNavigator.scrollSections = function(self, direction)
	direction = direction == "up" and -1 or 1
	local sections = self.gameController.settingsModel.sections

	if not sections[self.sectionItemIndex + direction] then
		return
	end

	self.sectionItemIndex = self.sectionItemIndex + direction
	self.settingItemIndex = 1
end

SettingsNavigator.scrollSettings = function(self, direction)
	direction = direction == "up" and -1 or 1
	local settings = self.gameController.settingsModel.sections[self.sectionItemIndex]

	if not settings[self.settingItemIndex + direction] then
		return
	end

	self.settingItemIndex = self.settingItemIndex + direction
end

SettingsNavigator.increaseSettingValue = function(self, itemIndex, delta)
	local settings = self.gameController.settingsModel.sections[self.sectionItemIndex]
	local settingConfig = settings[itemIndex or self.settingItemIndex]
	self:send({
		name = "increaseSettingValue",
		settingConfig = settingConfig,
		delta = delta
	})
end

SettingsNavigator.setSettingValue = function(self, itemIndex, value)
	local settings = self.gameController.settingsModel.sections[self.sectionItemIndex]
	local settingConfig = settings[itemIndex or self.settingItemIndex]
	self:send({
		name = "setSettingValue",
		settingConfig = settingConfig,
		value = value
	})
end

SettingsNavigator.resetSetting = function(self, itemIndex)
	self:send({
		name = "resetSettingsItem",
		sectionIndex = self.sectionItemIndex,
		settingIndex = itemIndex or self.settingItemIndex
	})
end

SettingsNavigator.setInputHandler = function(self, itemIndex)
	local settings = self.gameController.settingsModel.sections[self.sectionItemIndex]
	local settingConfig = settings[itemIndex or self.settingItemIndex]
	if settingConfig.type ~= "binding" then
		return
	end
	self.inputItemIndex = itemIndex or self.settingItemIndex
	self.activeElement = "inputHandler"
end

SettingsNavigator.setInputBinding = function(self, scancode)
	local settings = self.gameController.settingsModel.sections[self.sectionItemIndex]
	local settingConfig = settings[self.inputItemIndex]
	self:send({
		name = "setInputBinding",
		settingConfig = settingConfig,
		value = scancode
	})
	self.activeElement = "settings"
end

return SettingsNavigator
