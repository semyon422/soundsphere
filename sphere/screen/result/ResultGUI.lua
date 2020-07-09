local ScreenManager			= require("sphere.screen.ScreenManager")
local PointGraph			= require("sphere.screen.gameplay.PointGraph")
local NoteChartDataDisplay	= require("sphere.screen.select.NoteChartDataDisplay")
local ModifierDisplay		= require("sphere.screen.select.ModifierDisplay")
local ScoreDisplay			= require("sphere.screen.gameplay.ScoreDisplay")
local JudgeDisplay			= require("sphere.screen.result.JudgeDisplay")
local Animation				= require("sphere.screen.gameplay.Animation")

local GUI = require("sphere.ui.GUI")

local ResultGUI = GUI:new()

ResultGUI.classes = setmetatable({
	PointGraph = PointGraph,
	NoteChartDataDisplay = NoteChartDataDisplay,
	ModifierDisplay = ModifierDisplay,
	ScoreDisplay = ScoreDisplay,
	JudgeDisplay = JudgeDisplay,
	Animation = Animation
}, GUI.classes)

ResultGUI.functions = setmetatable({
}, GUI.functions)

return ResultGUI