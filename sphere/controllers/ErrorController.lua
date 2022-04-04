local Class = require("aqua.util.Class")

local ErrorController = Class:new()

ErrorController.load = function(self)
	local themeModel = self.gameController.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ErrorView")
	self.view = view

	view.controller = self
	view.gameController = self.gameController
	self.error = ""

	view:load()
end

ErrorController.unload = function(self)
	self.view:unload()
end

ErrorController.update = function(self, dt)
	self.view:update(dt)
end

ErrorController.draw = function(self)
	self.view:draw()
end

ErrorController.receive = function(self, event)
	self.view:receive(event)

	if event.name == "changeScreen" then
		self.gameController.screenManager:set(self.gameController.selectController)
	end
end

return ErrorController
