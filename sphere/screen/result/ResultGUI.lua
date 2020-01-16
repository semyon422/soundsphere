local ScreenManager			= require("sphere.screen.ScreenManager")
local AccuracyGraph			= require("sphere.screen.gameplay.AccuracyGraph")
local NoteChartDataDisplay	= require("sphere.screen.select.NoteChartDataDisplay")
local ModifierDisplay		= require("sphere.screen.select.ModifierDisplay")
local ScoreDisplay			= require("sphere.screen.gameplay.ScoreDisplay")

local GUI = require("sphere.ui.GUI")

local ResultGUI = GUI:new()

ResultGUI.classes = setmetatable({
	AccuracyGraph = AccuracyGraph,
	NoteChartDataDisplay = NoteChartDataDisplay,
	ModifierDisplay = ModifierDisplay,
	ScoreDisplay = ScoreDisplay
}, GUI.classes)

ResultGUI.functions = setmetatable({
}, GUI.functions)

return ResultGUI