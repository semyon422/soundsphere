local Class = require("aqua.util.Class")

local InputController = Class:new()


InputController.construct = function(self)
end

InputController.load = function(self)
	local noteChartModel = self.gameController.noteChartModel
	local themeModel = self.gameController.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("InputView")
	self.view = view

	view.controller = self
	view.themeModel = themeModel
	view.noteChartModel = self.gameController.noteChartModel
	view.inputModel = self.gameController.inputModel
	view.configModel = self.gameController.configModel
	view.backgroundModel = self.gameController.backgroundModel

	noteChartModel:load()

	view:load()
end

InputController.unload = function(self)
	self.view:unload()
end

InputController.update = function(self, dt)
	self.view:update(dt)
end

InputController.draw = function(self)
	self.view:draw()
end

InputController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "setInputBinding" then
		self.gameController.inputModel:setKey(event.inputMode, event.virtualKey, event.value, event.type)
	elseif event.name == "changeScreen" then
		self.gameController.screenManager:set(self.selectController)
	end
end

return InputController
