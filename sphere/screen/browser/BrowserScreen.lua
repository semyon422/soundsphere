local Config			= require("sphere.config.Config")
local Screen			= require("sphere.screen.Screen")
local ScreenManager		= require("sphere.screen.ScreenManager")
local BrowserList		= require("sphere.screen.browser.BrowserList")
local BackgroundManager	= require("sphere.ui.BackgroundManager")

local BrowserScreen = Screen:new()

BrowserScreen.init = function(self)
	BrowserList:init()
	BrowserList.observable:add(self)
end

BrowserScreen.load = function(self)
	BrowserList:load()
	
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
	if event.name == "keypressed" and event.args[1] == Config:get("screen.browser") then
		ScreenManager:set(require("sphere.screen.select.SelectScreen"))
	end
	
	BrowserList:receive(event)
end

return BrowserScreen
