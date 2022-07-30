local Navigator = require("sphere.views.Navigator")

local ResultNavigator = Navigator:new({construct = false})

ResultNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local s = event[2]
	if s == "up" then self.game.selectModel:scrollScore(-1)
	elseif s == "down" then self.game.selectModel:scrollScore(1)
	elseif s == "escape" then self.screenView:changeScreen("selectView")
	elseif s == "return" then self.screenView:loadScore()
	elseif s == "f1" then self.screenView.subscreen = "debug"
	elseif s == "f2" then self.screenView.subscreen = "scoreSystemDebug"
	elseif s == "f3" then self.screenView.subscreen = "countersDebug"
	elseif s == "f4" then self.screenView.subscreen = "scoreEntryDebug"
	end
end

return ResultNavigator
