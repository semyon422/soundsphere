local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Config			= require("sphere.config.Config")
local NoteSkinManager	= require("sphere.noteskin.NoteSkinManager")
local Screen			= require("sphere.screen.Screen")
local ScreenManager		= require("sphere.screen.ScreenManager")

local MetaDataTable		= require("sphere.screen.select.MetaDataTable")
local ModifierDisplay	= require("sphere.screen.select.ModifierDisplay")
local ModifierMenu		= require("sphere.screen.select.ModifierMenu")
local NoteChartList		= require("sphere.screen.select.NoteChartList")
local NoteChartSetList	= require("sphere.screen.select.NoteChartSetList")
local NoteSkinMenu		= require("sphere.screen.select.NoteSkinMenu")
local KeyBindMenu		= require("sphere.screen.select.KeyBindMenu")
local PreviewManager	= require("sphere.screen.select.PreviewManager")
local SearchLine		= require("sphere.screen.select.SearchLine")
local SelectFrame		= require("sphere.screen.select.SelectFrame")
local SelectGUI			= require("sphere.screen.select.SelectGUI")

local BackgroundManager	= require("sphere.ui.BackgroundManager")

local SelectScreen = Screen:new()

SelectScreen.init = function(self)
	self.gui = SelectGUI:new()
	self.gui.container = self.container
	self.gui:load("userdata/interface/select.json")

	MetaDataTable:init()
	ModifierDisplay:init()
	ModifierMenu:init()
	NoteSkinMenu:init()
	KeyBindMenu:init()
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
	self.gui:reload()
	
	NoteSkinManager:load()
	MetaDataTable:reload()
	
	NoteChartList:load()
	NoteChartSetList:load()
	
	ModifierDisplay:reload()
	
	SearchLine:reload()
	SelectFrame:reload()
	
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
	
	ModifierMenu:update()
	NoteSkinMenu:update()
	KeyBindMenu:update()
	self.gui:update()
end

SelectScreen.draw = function(self)
	Screen.draw(self)
	
	NoteChartSetList:draw()
	NoteChartList:draw()
	SelectFrame:draw()
	
	MetaDataTable:draw()
	SearchLine:draw()
	ModifierDisplay:draw()
	
	ModifierMenu:draw()
	NoteSkinMenu:draw()
	KeyBindMenu:draw()
end

SelectScreen.receive = function(self, event)
	local modifierMenuHidden = ModifierMenu.hidden
	local noteSkinMenuHidden = NoteSkinMenu.hidden
	local keyBindMenuMenuHidden = KeyBindMenu.hidden
	ModifierMenu:receive(event)
	NoteSkinMenu:receive(event)
	KeyBindMenu:receive(event)
	if (not modifierMenuHidden or not noteSkinMenuHidden or not keyBindMenuMenuHidden) and event.name ~= "resize" then
		return
	end
	
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
		SearchLine:reload()
		self.gui:reload()
		return
	end
	
	NoteChartSetList:receive(event)
	NoteChartList:receive(event)
	ModifierDisplay:receive(event)
	SearchLine:receive(event)
	self.gui:receive(event)
end

return SelectScreen
