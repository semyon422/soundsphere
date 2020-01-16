local NoteSkinMenu			= require("sphere.screen.select.NoteSkinMenu")
local ModifierMenu			= require("sphere.screen.select.ModifierMenu")
local KeyBindMenu			= require("sphere.screen.select.KeyBindMenu")
local NoteChartDataDisplay	= require("sphere.screen.select.NoteChartDataDisplay")
local ModifierDisplay		= require("sphere.screen.select.ModifierDisplay")
local SearchLine			= require("sphere.screen.select.SearchLine")
local ScreenManager			= require("sphere.screen.ScreenManager")

local GUI = require("sphere.ui.GUI")

local SelectGUI = GUI:new()

SelectGUI.classes = setmetatable({
	NoteChartDataDisplay = NoteChartDataDisplay,
	ModifierDisplay = ModifierDisplay,
	SearchLine = SearchLine
}, GUI.classes)

SelectGUI.functions = setmetatable({
	["NoteSkinMenu:show()"] = function() NoteSkinMenu:show() end,
	["ModifierMenu:show()"] = function() ModifierMenu:show() end,
	["KeyBindMenu:show()"] = function() KeyBindMenu:show() end,
	["ScreenManager:set(SettingsScreen)"] = function() ScreenManager:set(require("sphere.screen.settings.SettingsScreen")) end,
	["ScreenManager:set(BrowserScreen)"] = function() ScreenManager:set(require("sphere.screen.browser.BrowserScreen")) end,
	["ScreenManager:set(SelectScreen)"] = function() ScreenManager:set(require("sphere.screen.select.SelectScreen")) end
}, GUI.functions)

return SelectGUI