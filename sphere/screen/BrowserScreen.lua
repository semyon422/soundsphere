local Observable = require("aqua.util.Observable")
local Observer = require("aqua.util.Observer")

local Screen = require("sphere.screen.Screen")
local ScreenManager = require("sphere.screen.ScreenManager")
local BrowserList = require("sphere.game.BrowserList")

local BackgroundManager = require("sphere.ui.BackgroundManager")

local BrowserScreen = Screen:new()

Screen.construct(BrowserScreen)

BrowserScreen.load = function(self)
	self.browserList = BrowserList:new()
	self.browserList.observable:add(self)
	
	self.browserList:load()
	self.browserList:sendInitial()
	
	BackgroundManager:setColor({127, 127, 127})
end

BrowserScreen.unload = function(self)
	self.browserList:unload()
end

BrowserScreen.unload = function(self) end

BrowserScreen.update = function(self)
	Screen.update(self)
	
	self.browserList:update()
end

BrowserScreen.draw = function(self)
	Screen.draw(self)
	
	self.browserList:draw()
end

BrowserScreen.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "tab" then
		ScreenManager:set(require("sphere.screen.SelectionScreen"))
	end
	
	self.browserList:receive(event)
end

return BrowserScreen
