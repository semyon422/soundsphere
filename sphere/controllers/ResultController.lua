local Class				= require("aqua.util.Class")
local ScreenManager		= require("sphere.screen.ScreenManager")

local ResultController = Class:new()

ResultController.construct = function(self)
end

ResultController.load = function(self)
	local modifierModel = self.modifierModel
	local themeModel = self.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ResultView")
	self.view = view

	view.modifierModel = modifierModel

	view.scoreSystem = self.scoreSystem
	view.noteChartModel = self.noteChartModel
	view.configModel = self.configModel

	view:load()
end

ResultController.unload = function(self)
	self.view:unload()
end

ResultController.update = function(self, dt)
	self.view:update(dt)
end

ResultController.draw = function(self)
	self.view:draw()
end

ResultController.receive = function(self, event)
	self.controller:receive(event)
end

ResultController.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "escape" then
		return ScreenManager:set(self.selectController)
	end
end

return ResultController
