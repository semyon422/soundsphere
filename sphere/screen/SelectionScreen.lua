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
	self.noteChartList = NoteChartList:new()
	self.noteChartSetList = NoteChartSetList:new()
	
	self.noteChartList.noteChartSetList = self.noteChartSetList
	self.noteChartSetList.noteChartList = self.noteChartList
	
	self.noteChartList.observable:add(self)
	self.noteChartSetList.observable:add(self)
	
	self.noteChartList:load()
	self.noteChartSetList:load()
	self.noteChartSetList:sendInitial()
	
	BackgroundManager:setColor({127, 127, 127})
end

SelectionScreen.unload = function(self)
	self.noteChartSetList:unload()
	self.noteChartList:unload()
end

SelectionScreen.unload = function(self) end

SelectionScreen.update = function(self)
	Screen.update(self)
	
	self.noteChartSetList:update()
	self.noteChartList:update()
end

SelectionScreen.draw = function(self)
	Screen.draw(self)
	
	self.noteChartSetList:draw()
	self.noteChartList:draw()
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
	
	self.noteChartSetList:receive(event)
	self.noteChartList:receive(event)
end

return SelectionScreen
