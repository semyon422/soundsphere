local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Config			= require("sphere.config.Config")
local Screen			= require("sphere.screen.Screen")
local ScreenManager		= require("sphere.screen.ScreenManager")
local Footer			= require("sphere.screen.select.Footer")
local Header			= require("sphere.screen.select.Header")
local MetaDataTable		= require("sphere.screen.select.MetaDataTable")
local ModifierDisplay	= require("sphere.screen.select.ModifierDisplay")
local NoteChartList		= require("sphere.screen.select.NoteChartList")
local NoteChartSetList	= require("sphere.screen.select.NoteChartSetList")
local PreviewManager	= require("sphere.screen.select.PreviewManager")
local SearchLine		= require("sphere.screen.select.SearchLine")
local SelectFrame		= require("sphere.screen.select.SelectFrame")
local BackgroundManager	= require("sphere.ui.BackgroundManager")

local SelectScreen = Screen:new()

SelectScreen.init = function(self)
	Footer:init()
	Header:init()
	MetaDataTable:init()
	ModifierDisplay:init()
	SearchLine:init()
	NoteChartList:init()
	NoteChartSetList:init()
	PreviewManager:init()
	
	NoteChartList.observable:add(self)
	NoteChartSetList.observable:add(self)
	SearchLine.observable:add(self)
	
	NoteChartList.NoteChartSetList = NoteChartSetList
	NoteChartSetList.NoteChartList = NoteChartList
end

SelectScreen.load = function(self)
	MetaDataTable:reload()
	
	NoteChartList:load()
	NoteChartSetList:load()
	
	ModifierDisplay:reload()
	
	SearchLine:reload()
	SelectFrame:reload()
	Header:reload()
	Footer:reload()
	
	NoteChartSetList:sendState()
	
	local dim = 255 * (1 - Config:get("dim.select"))
	BackgroundManager:setColor({dim, dim, dim})
end

SelectScreen.unload = function(self)
	PreviewManager:stop()
end

SelectScreen.update = function(self)
	Screen.update(self)
	
	NoteChartSetList:update()
	NoteChartList:update()
	PreviewManager:update()
end

SelectScreen.draw = function(self)
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

SelectScreen.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == Config:get("screen.browser") then
		return ScreenManager:set(require("sphere.screen.browser.BrowserScreen"))
	elseif event.name == "keypressed" and event.args[1] == Config:get("screen.settings") then
		return ScreenManager:set(require("sphere.screen.settings.SettingsScreen"))
	elseif event.action == "updateMetaData" then
		return MetaDataTable:setData(event.cacheData)
	elseif event.backgroundPath then
		return BackgroundManager:loadDrawableBackground(event.backgroundPath)
	elseif event.name == "resize" then
		MetaDataTable:reload()
		ModifierDisplay:reload()
		SelectFrame:reload()
		NoteChartSetList:reload()
		NoteChartList:reload()
		Header:reload()
		Footer:reload()
		SearchLine:reload()
		return
	end
	
	NoteChartSetList:receive(event)
	NoteChartList:receive(event)
	ModifierDisplay:receive(event)
	Header:receive(event)
	Footer:receive(event)
	SearchLine:receive(event)
end

return SelectScreen
