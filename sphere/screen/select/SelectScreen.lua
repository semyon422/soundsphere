local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local NoteChartFactory	= require("notechart.NoteChartFactory")
local Config			= require("sphere.config.Config")
local NoteSkinManager	= require("sphere.noteskin.NoteSkinManager")
local Screen			= require("sphere.screen.Screen")
local ScreenManager		= require("sphere.screen.ScreenManager")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")

local ModifierMenu		= require("sphere.screen.select.ModifierMenu")
local NoteSkinMenu		= require("sphere.screen.select.NoteSkinMenu")
local KeyBindMenu		= require("sphere.screen.select.KeyBindMenu")
local NoteChartMenu		= require("sphere.screen.select.NoteChartMenu")

local NoteChartList		= require("sphere.screen.select.NoteChartList")
local NoteChartSetList	= require("sphere.screen.select.NoteChartSetList")
local PreviewManager	= require("sphere.screen.select.PreviewManager")
local SelectGUI			= require("sphere.screen.select.SelectGUI")

local BackgroundManager	= require("sphere.ui.BackgroundManager")

local NoteChartStateManager	= require("sphere.screen.select.NoteChartStateManager")

local SelectScreen = Screen:new()

SelectScreen.init = function(self)
	self.gui = SelectGUI:new()
	self.gui.container = self.container
	self.gui:load("userdata/interface/select.json")
	
	ModifierManager:init()
	
	ModifierMenu:init()
	NoteSkinMenu:init()
	KeyBindMenu:init()
	NoteChartMenu:init()

	NoteChartList:init()
	NoteChartSetList:init()
	PreviewManager:init()

	NoteChartStateManager:init()
	NoteChartStateManager.observable:add(self)
end

SelectScreen.getNoteChart = function(self)
	local item = NoteChartList.items[NoteChartList.focusedItemIndex]
	local noteChartDataEntry = item.noteChartDataEntry
	local noteChartEntry = item.noteChartEntry
	local path = noteChartEntry.path

	local file = love.filesystem.newFile(path)
	file:open("r")
	local content = file:read()
	file:close()
	
	local status, noteCharts = NoteChartFactory:getNoteCharts(
		path,
		content,
		noteChartDataEntry.index
	)
	return noteCharts[1]
end

SelectScreen.load = function(self)
	self.gui:reload()

	KeyBindMenu.SelectScreen = SelectScreen
	NoteSkinMenu.SelectScreen = SelectScreen
	
	NoteSkinManager:load()
	ModifierManager:load()
	ModifierMenu:reloadItems()
	
	NoteChartList:load()
	NoteChartSetList:load()
	
	NoteChartStateManager:load()
	
	NoteChartSetList:sendState()
	
	local dim = 255 * (1 - Config:get("dim.select"))
	BackgroundManager:setColor({dim, dim, dim})
end

SelectScreen.unload = function(self)
	PreviewManager:stop()
	ModifierManager:unload()
	NoteChartStateManager:unload()
end

SelectScreen.update = function(self)
	Screen.update(self)
	
	NoteChartSetList:update()
	NoteChartList:update()
	PreviewManager:update()
	
	ModifierMenu:update()
	NoteSkinMenu:update()
	KeyBindMenu:update()
	NoteChartMenu:update()

	self.gui:update()
end

SelectScreen.draw = function(self)
	NoteChartSetList:draw()
	NoteChartList:draw()
	
	Screen.draw(self)

	ModifierMenu:draw()
	NoteSkinMenu:draw()
	KeyBindMenu:draw()
	NoteChartMenu:draw()
end

SelectScreen.receive = function(self, event)
	local modifierMenuHidden = ModifierMenu.hidden
	local noteSkinMenuHidden = NoteSkinMenu.hidden
	local keyBindMenuMenuHidden = KeyBindMenu.hidden
	local noteChartMenuMenuHidden = NoteChartMenu.hidden
	ModifierMenu:receive(event)
	NoteSkinMenu:receive(event)
	KeyBindMenu:receive(event)
	NoteChartMenu:receive(event)
	if (
		not modifierMenuHidden or
		not noteSkinMenuHidden or
		not keyBindMenuMenuHidden or
		not noteChartMenuMenuHidden
		) and event.name ~= "resize" then
		return
	end
	
	if event.action == "playNoteChart" then
		if not love.filesystem.exists(event.noteChartEntry.path) then
			return
		end

		local GameplayScreen = require("sphere.screen.gameplay.GameplayScreen")
		GameplayScreen.noteChartEntry = event.noteChartEntry
		GameplayScreen.noteChartDataEntry = event.noteChartDataEntry
		return ScreenManager:set(GameplayScreen)
	elseif event.name == "keypressed" and event.args[1] == Config:get("screen.browser") then
		return ScreenManager:set(require("sphere.screen.browser.BrowserScreen"))
	elseif event.name == "keypressed" and event.args[1] == Config:get("screen.settings") then
		return ScreenManager:set(require("sphere.screen.settings.SettingsScreen"))
	elseif event.backgroundPath then
		return BackgroundManager:loadDrawableBackground(event.backgroundPath)
	elseif event.name == "resize" then
		NoteChartSetList:reload()
		NoteChartList:reload()
		self.gui:reload()
		return
	end
	
	NoteChartSetList:receive(event)
	NoteChartList:receive(event)
	self.gui:receive(event)
	NoteChartStateManager:receive(event)
end

return SelectScreen
