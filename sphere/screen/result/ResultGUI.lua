local ScreenManager = require("sphere.screen.ScreenManager")
local AccuracyGraph = require("sphere.screen.gameplay.AccuracyGraph")

local GUI = require("sphere.ui.GUI")

local ResultGUI = GUI:new()

ResultGUI.classes = setmetatable({
	AccuracyGraph = AccuracyGraph
}, GUI.classes)

ResultGUI.functions = setmetatable({
}, GUI.functions)

return ResultGUI