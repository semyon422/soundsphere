local Class					= require("aqua.util.Class")
local CollectionModel		= require("sphere.models.CollectionModel")

local BrowserController = Class:new()

BrowserController.construct = function(self)
	self.collectionModel = CollectionModel:new()
end

BrowserController.load = function(self)
	local themeModel = self.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	self.selectController.inputModel:load()

	local view = theme:newView("BrowserView")
	self.view = view

	view.controller = self
	view.cacheModel = self.cacheModel
	view.configModel = self.configModel
	view.collectionModel = self.collectionModel

	self.collectionModel.cacheModel = self.cacheModel

	view:load()
end

BrowserController.unload = function(self)
	self.selectController.inputModel:unload()
	self.view:unload()
end

BrowserController.update = function(self)
	self.view:update()
end

BrowserController.draw = function(self)
	self.view:draw()
end

BrowserController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "setScreen" then
		if event.screenName == "SelectScreen" then
			self.gameController.screenManager:set(self.selectController)
		elseif event.screenName == "SettingsScreen" then
			local SettingsController = require("sphere.controllers.SettingsController")
			local settingsController = SettingsController:new()
			settingsController.configModel = self.configModel
			settingsController.themeModel = self.themeModel
			settingsController.selectController = self.selectController
			return self.gameController.screenManager:set(settingsController)
		end
	end
end

return BrowserController
