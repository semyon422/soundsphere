local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local NoteChartFactory	= require("notechart.NoteChartFactory")
local GameConfig		= require("sphere.config.GameConfig")
-- local NoteSkinManager	= require("sphere.noteskin.NoteSkinManager")
local Screen			= require("sphere.screen.Screen")
local ScreenManager		= require("sphere.screen.ScreenManager")
-- local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local AliasManager		= require("sphere.database.AliasManager")

local ModifierMenu		= require("sphere.ui.ModifierMenu")
local NoteSkinMenu		= require("sphere.ui.NoteSkinMenu")
local KeyBindMenu		= require("sphere.ui.KeyBindMenu")
local NoteChartMenu		= require("sphere.ui.NoteChartMenu")

local ScoreList			= require("sphere.ui.ScoreList")
local NoteChartList		= require("sphere.ui.NoteChartList")
local NoteChartSetList	= require("sphere.ui.NoteChartSetList")
local PreviewManager	= require("sphere.ui.PreviewManager")

local BackgroundManager	= require("sphere.ui.BackgroundManager")

local NoteChartStateManager	= require("sphere.ui.NoteChartStateManager")
local GUI = require("sphere.ui.GUI")

local SelectView = Class:new()

SelectView.load = function(self)
    self.container = Container:new()

	self.gui = GUI:new()
	self.gui.container = self.container
	self.gui.modifierModel = self.modifierModel

	NoteChartStateManager.observable:add(self.gui)
	NoteChartStateManager.observable:add(self.controller)
	NoteChartStateManager.noteChartModel = self.noteChartModel

	self.gui:load("userdata/interface/select.json")
	self.gui:reload()

	KeyBindMenu.noteChartModel = self.noteChartModel
	NoteSkinMenu.noteChartModel = self.noteChartModel

	KeyBindMenu.modifierModel = self.modifierModel
	NoteSkinMenu.modifierModel = self.modifierModel
	ModifierMenu.modifierModel = self.modifierModel

	AliasManager:load()
	ModifierMenu:reloadItems()

	ScoreList:load()
	NoteChartList:load()
	NoteChartSetList:load()

	NoteChartStateManager:load()

	NoteChartSetList:sendState()

	local dim = 255 * (1 - GameConfig:get("dim.select"))
	BackgroundManager:setColor({dim, dim, dim})
end

SelectView.unload = function(self)
	self.gui:unload()
	PreviewManager:stop()
	NoteChartStateManager:unload()
end

SelectView.receive = function(self, event)
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

	if event.name == "resize" then
		NoteChartSetList:reload()
		NoteChartList:reload()
		ScoreList:reload()
		self.gui:reload()
		return
	elseif event.backgroundPath then
		return BackgroundManager:loadDrawableBackground(event.backgroundPath)
	elseif event.name == "keypressed" and event.args[1] == GameConfig:get("screen.browser") then
		return self.controller:receive({
			name = "setScreen",
			screenName = "BrowserScreen"
		})
	elseif event.name == "keypressed" and event.args[1] == GameConfig:get("screen.settings") then
		return self.controller:receive({
			name = "setScreen",
			screenName = "SettingsScreen"
		})
	end

	NoteChartSetList:receive(event)
	NoteChartList:receive(event)
	ScoreList:receive(event)
	self.gui:receive(event)
	NoteChartStateManager:receive(event)
end

SelectView.update = function(self, dt)
    self.container:update()

	ScoreList:update()
	NoteChartSetList:update()
	NoteChartList:update()
	PreviewManager:update()

	ModifierMenu:update()
	NoteSkinMenu:update()
	KeyBindMenu:update()
	NoteChartMenu:update()

	self.gui:update()
end

SelectView.draw = function(self)
	NoteChartSetList:draw()
	NoteChartList:draw()
	ScoreList:draw()

	self.container:draw()

	ModifierMenu:draw()
	NoteSkinMenu:draw()
	KeyBindMenu:draw()
	NoteChartMenu:draw()
end

return SelectView
