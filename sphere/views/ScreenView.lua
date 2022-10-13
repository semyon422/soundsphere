local Class = require("Class")

local ScreenView = Class:new()

ScreenView.changeScreen = function(self, screenName, noTransition)
	self.gameView:setView(self.game[screenName], noTransition)
end

ScreenView.load = function(self) end
ScreenView.unload = function(self) end
ScreenView.receive = function(self, event) end
ScreenView.update = function(self, dt) end
ScreenView.draw = function(self) end

return ScreenView
