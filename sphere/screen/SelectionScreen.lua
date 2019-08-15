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
local SelectFrame = require("sphere.ui.SelectFrame")
local Header = require("sphere.ui.Header")
local Footer = require("sphere.ui.Footer")
local Config = require("sphere.game.Config")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local SelectionScreen = Screen:new()

Screen.construct(SelectionScreen)

SelectionScreen.load = function(self)
	MetaDataTable:load()
	
	NoteChartList.NoteChartSetList = NoteChartSetList
	NoteChartSetList.NoteChartList = NoteChartList
	
	NoteChartList.observable:add(self)
	NoteChartSetList.observable:add(self)
	
	NoteChartList:load()
	NoteChartSetList:load()
	
	ModifierDisplay:reload()
	
	SearchLine:load()
	Header:load()
	Footer:load()
	
	NoteChartSetList:sendInitial()
	
	SelectFrame:reload()
	
	local dim = 255 * (1 - Config.data.dim.selection)
	BackgroundManager:setColor({dim, dim, dim})
end

SelectionScreen.unload = function(self)
	NoteChartSetList:unload()
	NoteChartList:unload()
	ModifierDisplay:unload()
end

SelectionScreen.unload = function(self) end

SelectionScreen.update = function(self)
	Screen.update(self)
	
	NoteChartSetList:update()
	NoteChartList:update()
	ModifierDisplay:update()
	PreviewManager:update()
end

SelectionScreen.draw = function(self)
	Screen.draw(self)
	
	NoteChartSetList:draw()
	NoteChartList:draw()
	SelectFrame:draw()
	
	Header:draw()
	Footer:draw()
	
	MetaDataTable:draw()
	SearchLine:draw()
	ModifierDisplay:draw()
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
		SelectFrame:reload()
	end
	
	NoteChartSetList:receive(event)
	NoteChartList:receive(event)
	ModifierDisplay:receive(event)
	Header:receive(event)
	Footer:receive(event)
	
	SearchLine:receive(event)
end

return SelectionScreen
