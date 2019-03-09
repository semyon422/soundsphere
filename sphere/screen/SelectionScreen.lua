local Observable = require("aqua.util.Observable")
local Observer = require("aqua.util.Observer")

local Screen = require("sphere.screen.Screen")
local MapList = require("sphere.game.MapList")
local NoteChartSetList = require("sphere.game.NoteChartSetList")
-- local NoteChartList = require("sphere.game.NoteChartList")
local MetaDataTable = require("sphere.ui.MetaDataTable")

local BackgroundManager = require("sphere.ui.BackgroundManager")

local SelectionScreen = Screen:new()

Screen.construct(SelectionScreen)

SelectionScreen.load = function(self)
	NoteChartSetList:load()
	NoteChartSetList.observable:add(self)
	-- NoteChartList:load()
	-- NoteChartList.observable:add(self)
	BackgroundManager:setColor({127, 127, 127})
end

SelectionScreen.unload = function(self)
	NoteChartSetList:unload()
	-- NoteChartList:unload()
end

SelectionScreen.unload = function(self) end

SelectionScreen.update = function(self)
	Screen.update(self)
	
	NoteChartSetList:update()
	-- NoteChartList:update()
end

SelectionScreen.draw = function(self)
	Screen.draw(self)
	
	NoteChartSetList:draw()
	-- NoteChartList:draw()
	MetaDataTable:draw()
end

SelectionScreen.receive = function(self, event)
	if event.cacheData then
		return MetaDataTable:setData(event.cacheData)
	end
	
	if event.name == "resize" then
		MetaDataTable:reload()
	end
	
	NoteChartSetList:receive(event)
	-- NoteChartList:receive(event)
end

return SelectionScreen
