local Class				= require("aqua.util.Class")
local ScreenManager		= require("sphere.screen.ScreenManager")
local ConfigController	= require("sphere.controllers.ConfigController")
local SettingsView		= require("sphere.views.SettingsView")

local SettingsController = Class:new()

SettingsController.construct = function(self)
	self.view = SettingsView:new()
	self.configController = ConfigController:new()
end

SettingsController.load = function(self)
	local configModel = self.configModel
	local view = self.view
	local configController = self.configController

	view.controller = self
	view.configModel = configModel

	configController.configModel = configModel

	view:load()
end

SettingsController.unload = function(self)
	self.configModel:write()
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
	self.configController:receive(event)

	if event.name == "keypressed" and event.args[1] == self.configModel:get("screen.settings") then
		local SelectController = require("sphere.controllers.SelectController")
		local selectController = SelectController:new()
		selectController.configModel = self.configModel
		return ScreenManager:set(selectController)
	end
end

return SettingsController
