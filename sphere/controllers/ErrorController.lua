local Class = require("aqua.util.Class")

local ErrorController = Class:new()

ErrorController.load = function(self)
	local themeModel = self.game.themeModel

	local theme = themeModel:getTheme()
	self.theme = theme

	local view = theme:newView("ErrorView")
	self.view = view

	view.controller = self
	view.game = self.game
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
		self.game.screenManager:set(self.game.selectController)
	end
end

return ErrorController
