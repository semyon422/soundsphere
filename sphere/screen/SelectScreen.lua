local Screen			= require("sphere.screen.Screen")
local SelectView	= require("sphere.views.SelectView")
local SelectController	= require("sphere.controllers.SelectController")

local SelectScreen = Screen:new()

SelectScreen.load = function(self)
	self.view = SelectView:new()
	self.controller = SelectController:new()

	self.view.controller = self.controller
	self.controller.view = self.view

	self.view:load()
	self.controller:load()
end

SelectScreen.unload = function(self)
	self.view:unload()
end

SelectScreen.update = function(self, dt)
	self.view:update(dt)
end

SelectScreen.draw = function(self)
	self.view:draw()
end

SelectScreen.receive = function(self, event)
	self.controller:receive(event)
end

return SelectScreen
