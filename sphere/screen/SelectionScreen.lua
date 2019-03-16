local Observable = require("aqua.util.Observable")
local Observer = require("aqua.util.Observer")

local Screen = require("sphere.screen.Screen")
local NoteChartSetList = require("sphere.game.NoteChartSetList")
local NoteChartList = require("sphere.game.NoteChartList")
local CustomList = require("sphere.game.CustomList")
local MetaDataTable = require("sphere.ui.MetaDataTable")
local ScreenManager = require("sphere.screen.ScreenManager")

local BackgroundManager = require("sphere.ui.BackgroundManager")

local SelectionScreen = Screen:new()

Screen.construct(SelectionScreen)

SelectionScreen.load = function(self)
	NoteChartList.NoteChartSetList = NoteChartSetList
	NoteChartSetList.NoteChartList = NoteChartList
	
	NoteChartList.observable:add(self)
	NoteChartSetList.observable:add(self)
	
	NoteChartList:load()
	NoteChartSetList:load()
	NoteChartSetList:sendInitial()
	
	BackgroundManager:setColor({127, 127, 127})
end

SelectionScreen.unload = function(self)
	NoteChartSetList:unload()
	NoteChartList:unload()
end

SelectionScreen.unload = function(self) end

SelectionScreen.update = function(self)
	Screen.update(self)
	
	NoteChartSetList:update()
	NoteChartList:update()
end

SelectionScreen.draw = function(self)
	Screen.draw(self)
	
	NoteChartSetList:draw()
	NoteChartList:draw()
	MetaDataTable:draw()
end

SelectionScreen.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "tab" then
		ScreenManager:set(require("sphere.screen.BrowserScreen"))
	end
	
	if event.action == "scrollTarget" then
		local cacheData = event.list.items[event.itemIndex].cacheData
		if cacheData then
			MetaDataTable:setData(cacheData)
		end
	end
	if event.backgroundPath then
		BackgroundManager:loadDrawableBackground(event.backgroundPath)
	end
	
	if event.name == "resize" then
		MetaDataTable:reload()
	end
	
	NoteChartSetList:receive(event)
	NoteChartList:receive(event)
end

return SelectionScreen
