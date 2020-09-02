local Class = require("aqua.util.Class")

local ResultView = Class:new()

ResultView.construct = function(self)
end

ResultView.load = function(self)
end

ResultView.unload = function(self)
end

ResultView.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "escape" then
		self.controller:receive({
			name = "setScreen",
			screenName = "SelectScreen"
		})
	end
end

ResultView.update = function(self, dt)
end

ResultView.draw = function(self)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(self.scoreSystem.scoreTable.score)
end

return ResultView
