local ScreenManager	= require("sphere.screen.ScreenManager")
local PointGraph	= require("sphere.screen.gameplay.PointGraph")
local ProgressBar	= require("sphere.screen.gameplay.ProgressBar")
local InputImage	= require("sphere.screen.gameplay.InputImage")
local ScoreDisplay	= require("sphere.screen.gameplay.ScoreDisplay")
local StaticObject	= require("sphere.screen.gameplay.StaticObject")

local GUI = require("sphere.ui.GUI")

local GameplayGUI = GUI:new()

GameplayGUI.classes = setmetatable({
	PointGraph = PointGraph,
	ProgressBar = ProgressBar,
	InputImage = InputImage,
	ScoreDisplay = ScoreDisplay,
	StaticObject = StaticObject
}, GUI.classes)

GameplayGUI.functions = setmetatable({
	-- ["NoteSkinMenu:show()"] = function() NoteSkinMenu:show() end,
	-- ["ModifierMenu:show()"] = function() ModifierMenu:show() end,
	-- ["KeyBindMenu:show()"] = function() KeyBindMenu:show() end,
	-- ["ScreenManager:set(SettingsScreen)"] = function() ScreenManager:set(require("sphere.screen.settings.SettingsScreen")) end
}, GUI.functions)

return GameplayGUI