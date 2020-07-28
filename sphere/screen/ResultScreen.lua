local Screen			= require("sphere.screen.Screen")
local ResultView		= require("sphere.views.ResultView")
local ResultController	= require("sphere.controllers.ResultController")
local ModifierModel		= require("sphere.models.ModifierModel")

local ResultScreen = Screen:new()

ResultScreen.load = function(self)
	local modifierModel = ModifierModel:new()
	local view = ResultView:new()
	local controller = ResultController:new()

	self.view = view
	self.controller = controller

	controller.view = view

	view.modifierModel = modifierModel

	modifierModel:load()
	view:load()
end

ResultScreen.unload = function(self)
	self.view:unload()
end

ResultScreen.update = function(self, dt)
	self.view:update(dt)
end

ResultScreen.draw = function(self)
	self.view:draw()
end

ResultScreen.receive = function(self, event)
	self.controller:receive(event)
end

return ResultScreen
