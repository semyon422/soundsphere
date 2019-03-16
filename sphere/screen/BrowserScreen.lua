local Observable = require("aqua.util.Observable")
local Observer = require("aqua.util.Observer")

local Screen = require("sphere.screen.Screen")
local ScreenManager = require("sphere.screen.ScreenManager")
local BrowserList = require("sphere.game.BrowserList")

local BackgroundManager = require("sphere.ui.BackgroundManager")

local BrowserScreen = Screen:new()

Screen.construct(BrowserScreen)

BrowserScreen.load = function(self)
	BrowserList.observable:add(self)
	
	BrowserList:load()
	BrowserList:sendInitial()
	
	BackgroundManager:setColor({127, 127, 127})
end

BrowserScreen.unload = function(self)
	BrowserList:unload()
end

BrowserScreen.update = function(self)
	Screen.update(self)
	
	BrowserList:update()
end

BrowserScreen.draw = function(self)
	Screen.draw(self)
	
	BrowserList:draw()
end

BrowserScreen.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "tab" then
		ScreenManager:set(require("sphere.screen.SelectionScreen"))
	end
	
	BrowserList:receive(event)
end

return BrowserScreen
