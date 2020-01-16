local ScreenManager			= require("sphere.screen.ScreenManager")

local GUI = require("sphere.ui.GUI")

local SettingsGUI = GUI:new()

SettingsGUI.classes = setmetatable({
}, GUI.classes)

SettingsGUI.functions = setmetatable({
	["ScreenManager:set(SettingsScreen)"] = function() ScreenManager:set(require("sphere.screen.settings.SettingsScreen")) end,
	["ScreenManager:set(BrowserScreen)"] = function() ScreenManager:set(require("sphere.screen.browser.BrowserScreen")) end,
	["ScreenManager:set(SelectScreen)"] = function() ScreenManager:set(require("sphere.screen.select.SelectScreen")) end
}, GUI.functions)

return SettingsGUI