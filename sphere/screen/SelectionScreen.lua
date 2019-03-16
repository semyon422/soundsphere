local Screen = require("sphere.screen.Screen")
local NoteChartSetList = require("sphere.ui.NoteChartSetList")
local NoteChartList = require("sphere.ui.NoteChartList")
local ModifierList = require("sphere.ui.ModifierList")
local MetaDataTable = require("sphere.ui.MetaDataTable")
local ScreenManager = require("sphere.screen.ScreenManager")
local ModifierDisplay = require("sphere.ui.ModifierDisplay")
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
	
	ModifierList:load()
	ModifierDisplay:reload()
	
	BackgroundManager:setColor({127, 127, 127})
end

SelectionScreen.unload = function(self)
	NoteChartSetList:unload()
	NoteChartList:unload()
	ModifierList:unload()
	ModifierDisplay:unload()
end

SelectionScreen.unload = function(self) end

SelectionScreen.update = function(self)
	Screen.update(self)
	
	NoteChartSetList:update()
	NoteChartList:update()
	ModifierList:update()
	ModifierDisplay:update()
end

SelectionScreen.draw = function(self)
	Screen.draw(self)
	
	NoteChartSetList:draw()
	NoteChartList:draw()
	ModifierList:draw()
	ModifierDisplay:draw()
	MetaDataTable:draw()
end

SelectionScreen.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "tab" then
		ScreenManager:set(require("sphere.screen.BrowserScreen"))
	end
	
	if event.action == "scrollTarget" then
		local item = event.list.items[event.itemIndex]
		if item and item.cacheData then
			MetaDataTable:setData(item.cacheData)
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
	ModifierList:receive(event)
	ModifierDisplay:receive(event)
end

return SelectionScreen
