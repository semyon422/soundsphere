local Class = require("aqua.util.Class")

local NoteSkinController = Class:new()

NoteSkinController.load = function(self)
	local noteChartModel = self.gameController.noteChartModel
	local themeModel = self.gameController.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("NoteSkinView")
	self.view = view

	view.controller = self
	view.gameController = self.gameController

	noteChartModel:load()

	view:load()
end

NoteSkinController.unload = function(self)
	self.view:unload()
end

NoteSkinController.update = function(self, dt)
	self.view:update(dt)
end

NoteSkinController.draw = function(self)
	self.view:draw()
end

NoteSkinController.receive = function(self, event)
	self.view:receive(event)

    if event.name == "setNoteSkin" then
		self.gameController.noteSkinModel:setDefaultNoteSkin(event.noteSkin)
	elseif event.name == "changeScreen" then
		self.gameController.screenManager:set(self.selectController)
	end
end

return NoteSkinController
