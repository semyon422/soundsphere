local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local SettingsNavigator = Navigator:new()

SettingsNavigator.construct = function(self)
	Navigator.construct(self)

	self.activeElement = "categories"
	self.sectionItemIndex = 1
	self.settingItemIndex = 1
end

SettingsNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event.args[2]
	if self.activeElement == "settings" then
		if scancode == "up" then self:scrollSettings("up")
		elseif scancode == "down" then self:scrollSettings("down")
		elseif scancode == "return" then
		elseif scancode == "backspace" then self:resetSetting()
		elseif scancode == "right" then self:increaseSettingValue(nil, 1)
		elseif scancode == "left" then self:increaseSettingValue(nil, -1)
		elseif scancode == "escape" then self.activeElement = "categories"
		end
	elseif self.activeElement == "categories" then
		if scancode == "up" then self:scrollCategories("up")
		elseif scancode == "down" then self:scrollCategories("down")
		elseif scancode == "return" then self.activeElement = "settings"
		elseif scancode == "escape" then self:changeScreen("Select")
		end
	end
end

SettingsNavigator.scrollCategories = function(self, direction, destination)
	local sectionsList = self.sectionsList

	local sections = self.view.settingsModel.sections

	direction = direction or destination - sectionsList.selected
	if not sections[sectionsList.selected + direction] then
		return
	end

	sectionsList.selected = sectionsList.selected + direction
end

SettingsNavigator.scrollSettings = function(self, direction, destination)
	local settingsList = self.settingsList
	local sectionsList = self.sectionsList

	local settings = self.view.settingsModel.sections[sectionsList.selected]

	direction = direction or destination - settingsList.selected
	if not settings[settingsList.selected + direction] then
		return
	end

	settingsList.selected = settingsList.selected + direction
end

SettingsNavigator.increaseSettingValue = function(self, direction, destination)
	local settings = self.view.settingsModel.sections[sectionsList.selected]
	local settingConfig = settings[itemIndex or settingsList.selected]
	self:send({
		name = "increaseSettingValue",
		settingConfig = settingConfig
	})
end

SettingsNavigator.resetSetting = function(self, direction, destination)
	self:send({
		name = "resetSettingsItem",
		sectionIndex = sectionsList.selected,
		settingIndex = itemIndex or settingsList.selected
	})
end

SettingsNavigator.setInputBinding = function(self, direction, destination)

	local settings = self.view.settingsModel.sections[sectionsList.selected]
	local settingConfig = inputHandler.settingConfig or settings[settingsList.selected]
	self:send({
		name = "setInputBinding",
		settingConfig = settingConfig,
		value = key,
		type = type
	})
	self.node = settingsList
end

return SettingsNavigator
