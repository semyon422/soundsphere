local NoteSkinMenu = require("sphere.screen.select.NoteSkinMenu")
local ModifierMenu = require("sphere.screen.select.ModifierMenu")
local KeyBindMenu = require("sphere.screen.select.KeyBindMenu")
local ScreenManager = require("sphere.screen.ScreenManager")

local GUI = require("sphere.ui.GUI")

local SelectGUI = GUI:new()

SelectGUI.classes = setmetatable({
	--
}, GUI.classes)

SelectGUI.functions = setmetatable({
	["NoteSkinMenu:show()"] = function() NoteSkinMenu:show() end,
	["ModifierMenu:show()"] = function() ModifierMenu:show() end,
	["KeyBindMenu:show()"] = function() KeyBindMenu:show() end,
	["ScreenManager:set(SettingsScreen)"] = function() ScreenManager:set(require("sphere.screen.settings.SettingsScreen")) end
}, GUI.functions)

return SelectGUI