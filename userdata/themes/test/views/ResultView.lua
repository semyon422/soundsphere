local Class = require("aqua.util.Class")

local ResultView = Class:new()

ResultView.construct = function(self)
end

ResultView.load = function(self)
end

ResultView.unload = function(self)
end

ResultView.receive = function(self, event)
end

ResultView.update = function(self, dt)
end

ResultView.draw = function(self)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(self.scoreSystem.scoreTable.score)
end

return ResultView
