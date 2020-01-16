local Config			= require("sphere.config.Config")
local Screen			= require("sphere.screen.Screen")
local ScreenManager		= require("sphere.screen.ScreenManager")
local BrowserList		= require("sphere.screen.browser.BrowserList")
local BrowserGUI		= require("sphere.screen.browser.BrowserGUI")
local BackgroundManager	= require("sphere.ui.BackgroundManager")

local BrowserScreen = Screen:new()

BrowserScreen.init = function(self)
	self.gui = BrowserGUI:new()
	self.gui.container = self.container
	self.gui:load("userdata/interface/browser.json")

	BrowserList:init()
	BrowserList.observable:add(self)
end

BrowserScreen.load = function(self)
	self.gui:reload()

	BrowserList:load()
	
	BackgroundManager:setColor({127, 127, 127})
end

BrowserScreen.unload = function(self)
	BrowserList:unload()
end

BrowserScreen.update = function(self)
	Screen.update(self)
	
	BrowserList:update()

	self.gui:update()
end

BrowserScreen.draw = function(self)
	BrowserList:draw()

	Screen.draw(self)
end

BrowserScreen.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == Config:get("screen.browser") then
		ScreenManager:set(require("sphere.screen.select.SelectScreen"))
	end
	
	BrowserList:receive(event)
	self.gui:receive(event)
end

return BrowserScreen
