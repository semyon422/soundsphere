local Class				= require("aqua.util.Class")

local ResultController = Class:new()

ResultController.load = function(self)
	local modifierModel = self.gameController.modifierModel
	local themeModel = self.gameController.themeModel
	local noteChartModel = self.gameController.noteChartModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ResultView")
	self.view = view

	view.modifierModel = modifierModel
	view.controller = self

	view.rhythmModel = self.rhythmModel
	view.noteChartModel = noteChartModel
	view.configModel = self.gameController.configModel
	view.backgroundModel = self.gameController.backgroundModel

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
		return self.gameController.screenManager:set(self.selectController)
	end
end

return ResultController
