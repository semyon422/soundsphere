local Class					= require("aqua.util.Class")
local ScreenManager			= require("sphere.screen.ScreenManager")
local CollectionModel		= require("sphere.models.CollectionModel")
local BrowserView			= require("sphere.views.BrowserView")

local BrowserController = Class:new()

BrowserController.construct = function(self)
	self.collectionModel = CollectionModel:new()
	self.view = BrowserView:new()
end

BrowserController.load = function(self)
	local view = self.view

	view.controller = self
	view.cacheModel = self.cacheModel
	view.collectionModel = self.collectionModel

	self.collectionModel.cacheModel = self.cacheModel

	view:load()
end

BrowserController.unload = function(self)
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

	if event.name == "keypressed" and event.args[1] == self.configModel:get("screen.browser") then
		local SelectController = require("sphere.controllers.SelectController")
		local selectController = SelectController:new()
		selectController.configModel = self.configModel
		ScreenManager:set(selectController)
	end
end

return BrowserController
