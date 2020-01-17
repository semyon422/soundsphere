local ScreenManager			= require("sphere.screen.ScreenManager")
local CacheManagerDisplay	= require("sphere.screen.browser.CacheManagerDisplay")

local GUI = require("sphere.ui.GUI")

local BrowserGUI = GUI:new()

BrowserGUI.classes = setmetatable({
	CacheManagerDisplay = CacheManagerDisplay
}, GUI.classes)

BrowserGUI.functions = setmetatable({
	["ScreenManager:set(SettingsScreen)"] = function() ScreenManager:set(require("sphere.screen.settings.SettingsScreen")) end,
	["ScreenManager:set(BrowserScreen)"] = function() ScreenManager:set(require("sphere.screen.browser.BrowserScreen")) end,
	["ScreenManager:set(SelectScreen)"] = function() ScreenManager:set(require("sphere.screen.select.SelectScreen")) end,
	["CacheMenu:show()"] = function() CacheMenu:show() end
}, GUI.functions)

return BrowserGUI