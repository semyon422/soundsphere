local Class = require("aqua.util.Class")

local GameView = Class:new()

GameView.load = function(self)
	self.game:setView(self.game.selectView)
end

GameView.unload = function(self) end
GameView.update = function(self, dt) end
GameView.draw = function(self) end
GameView.receive = function(self, event) end

return GameView
