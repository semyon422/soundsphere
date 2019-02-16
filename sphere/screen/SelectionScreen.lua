local Observable = require("aqua.util.Observable")
local Observer = require("aqua.util.Observer")

local Screen = require("sphere.screen.Screen")
local MapList = require("sphere.game.MapList")
local MetaDataTable = require("sphere.ui.MetaDataTable")

local BackgroundManager = require("sphere.ui.BackgroundManager")

local SelectionScreen = Screen:new()

Screen.construct(SelectionScreen)

SelectionScreen.load = function(self)
	BackgroundManager:setColor({191, 191, 191})
	MapList:load()
	MapList.observable:add(self)
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
	MetaDataTable:draw()
end

SelectionScreen.receive = function(self, event)
	if event.cacheData then
		return MetaDataTable:setData(event.cacheData)
	end
	
	if event.name == "resize" then
		MetaDataTable:reload()
	end
	
	MapList:receive(event)
end

return SelectionScreen
