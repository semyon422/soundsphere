local Class				= require("aqua.util.Class")
local ScreenManager		= require("sphere.screen.ScreenManager")

local ResultController = Class:new()

ResultController.load = function(self)
	local modifierModel = self.modifierModel
	local themeModel = self.themeModel
	local noteChartModel = self.noteChartModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ResultView")
	self.view = view

	view.modifierModel = modifierModel
	view.controller = self

	view.scoreSystem = self.scoreSystem
	view.noteChartModel = noteChartModel
	view.configModel = self.configModel
	view.backgroundModel = self.backgroundModel

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
	self.view:receive(event)

	if event.name == "goSelectScreen" then
		return ScreenManager:set(self.selectController)
	end
end

return ResultController
