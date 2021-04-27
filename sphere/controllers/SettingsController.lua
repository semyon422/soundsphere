local Class = require("aqua.util.Class")

local SettingsController = Class:new()

SettingsController.construct = function(self) end

SettingsController.load = function(self)
	local themeModel = self.gameController.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("SettingsView")
	self.view = view

	view.controller = self
	view.configModel = self.gameController.configModel
	view.settingsModel = self.gameController.settingsModel
	view.backgroundModel = self.gameController.backgroundModel

	view:load()
end

SettingsController.unload = function(self)
	self.view:unload()
end

SettingsController.update = function(self)
	self.view:update()
end

SettingsController.draw = function(self)
	self.view:draw()
end

SettingsController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "goSelectScreen" then
		return self.gameController.screenManager:set(self.selectController)
	elseif event.name == "setSettingValue" then
		self.gameController.settingsModel:setValue(event.settingConfig, event.value)
	elseif event.name == "increaseSettingValue" then
		self.gameController.settingsModel:increaseValue(event.settingConfig, 1)
	elseif event.name == "decreaseSettingValue" then
		self.gameController.settingsModel:increaseValue(event.settingConfig, -1)
	end
end

return SettingsController
