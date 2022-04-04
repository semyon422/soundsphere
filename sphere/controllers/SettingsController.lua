local Class = require("aqua.util.Class")

local SettingsController = Class:new()

SettingsController.load = function(self)
	local themeModel = self.gameController.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("SettingsView")
	self.view = view

	view.controller = self
	view.gameController = self.gameController

	view:load()
end

SettingsController.unload = function(self)
	self.view:unload()
end

SettingsController.update = function(self, dt)
	self.view:update(dt)
end

SettingsController.draw = function(self)
	self.view:draw()
end

SettingsController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "setSettingValue" then
		self.gameController.settingsModel:setValue(event.settingConfig, event.value)
	elseif event.name == "increaseSettingValue" then
		self.gameController.settingsModel:increaseValue(event.settingConfig, event.delta)
	elseif event.name == "decreaseSettingValue" then
	elseif event.name == "setInputBinding" then
		self.gameController.settingsModel:setValue(event.settingConfig, event.value)
	elseif event.name == "changeScreen" then
		self.gameController.screenManager:set(self.selectController)
	end
end

return SettingsController
