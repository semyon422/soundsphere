local Screen = require("sphere.screen.Screen")
local MapList = require("sphere.game.MapList")

local SelectionScreen = Screen:new()

Screen.construct(SelectionScreen)

SelectionScreen.load = function(self)
	MapList:load()
end

SelectionScreen.unload = function(self)
	MapList:unload()
end

SelectionScreen.unload = function(self) end

SelectionScreen.update = function(self)
	Screen.update(self)
	
	MapList:update()
end

SelectionScreen.draw = function(self)
	Screen.draw(self)
	
	MapList:draw()
end

SelectionScreen.receive = function(self, event)
	MapList:receive(event)
end

return SelectionScreen
