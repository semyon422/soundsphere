local Class = require("aqua.util.Class")
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


local SelectController = Class:new()

SelectController.load = function(self)
end

SelectController.receive = function(self, event)
	if event.name == "setNoteSkin" then
		self.noteSkinModel:setDefaultNoteSkin(event.inputMode, event.metaData)
	end

	if event.name == "selectNoteChart" then
		if event.type == "noteChartEntry" then
			self.noteChartModel:selectNoteChart(event.id)
		elseif event.type == "noteChartSetEntry" then
			self.noteChartModel:selectNoteChartSet(event.id)
		end
	elseif event.action == "playNoteChart" then
		if not love.filesystem.exists(event.noteChartEntry.path) then
			return
		end
		if event.noteChartDataEntry.hash == "" then
			return
		end

		local GameplayScreen = require("sphere.screen.GameplayScreen")
		GameplayScreen.noteChartEntry = event.noteChartEntry
		GameplayScreen.noteChartDataEntry = event.noteChartDataEntry
		return ScreenManager:set(require("sphere.screen.GameplayScreen"))
	elseif event.name == "setScreen" then
		if event.screenName == "BrowserScreen" then
			return ScreenManager:set(require("sphere.screen.browser.BrowserScreen"))
		elseif event.screenName == "SettingsScreen" then
			return ScreenManager:set(require("sphere.screen.settings.SettingsScreen"))
		end
	end
end

return SelectController
