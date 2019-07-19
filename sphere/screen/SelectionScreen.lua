local Screen = require("sphere.screen.Screen")
local NoteChartSetList = require("sphere.ui.NoteChartSetList")
local NoteChartList = require("sphere.ui.NoteChartList")
local ModifierList = require("sphere.ui.ModifierList")
local MetaDataTable = require("sphere.ui.MetaDataTable")
local ScreenManager = require("sphere.screen.ScreenManager")
local ModifierDisplay = require("sphere.ui.ModifierDisplay")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local PreviewManager = require("sphere.ui.PreviewManager")
local SearchLine = require("sphere.ui.SearchLine")
local TableMenu = require("sphere.ui.TableMenu")
local Config = require("sphere.game.Config")

local SelectionScreen = Screen:new()

Screen.construct(SelectionScreen)

SelectionScreen.load = function(self)
	self.tableMenu = TableMenu:new({
		x = 0,
		y = 0,
		w = 1,
		h = 1,
		cols = 10,
		rows = 17
	})
	self.tableMenu:apply(NoteChartSetList, 7, 1, 10, 17)
	self.tableMenu:apply(NoteChartList, 1, 5, 6, 13)
	self.tableMenu:apply(SearchLine, 1, 1, 6, 1, 0.005)
	self.tableMenu:apply(ModifierList, 1, 14, 4, 16)
	self.tableMenu:apply(ModifierDisplay, 1, 17, 6, 17)
	
	NoteChartList.NoteChartSetList = NoteChartSetList
	NoteChartSetList.NoteChartList = NoteChartList
	
	NoteChartList.observable:add(self)
	NoteChartSetList.observable:add(self)
	
	NoteChartList:load()
	NoteChartSetList:load()
	
	ModifierList:load()
	ModifierDisplay:reload()
	
	NoteChartSetList:sendInitial()
	
	SearchLine:load()
	
	local dim = 255 * (1 - Config.data.dim.selection)
	BackgroundManager:setColor({dim, dim, dim})
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
	PreviewManager:update()
end

SelectionScreen.draw = function(self)
	Screen.draw(self)
	
	NoteChartSetList:draw()
	NoteChartList:draw()
	ModifierList:draw()
	ModifierDisplay:draw()
	MetaDataTable:draw()
	
	SearchLine:draw()
end

SelectionScreen.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "tab" then
		ScreenManager:set(require("sphere.screen.BrowserScreen"))
	end
	
	if event.action == "updateMetaData" then
		MetaDataTable:setData(event.cacheData)
	end
	if event.backgroundPath then
		BackgroundManager:loadDrawableBackground(event.backgroundPath)
	end
	
	if event.name == "resize" then
		MetaDataTable:reload()
		ModifierDisplay:reload()
	end
	
	NoteChartSetList:receive(event)
	NoteChartList:receive(event)
	ModifierList:receive(event)
	ModifierDisplay:receive(event)
	
	SearchLine:receive(event)
end

return SelectionScreen
