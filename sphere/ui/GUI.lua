local json					= require("json")
local Class					= require("aqua.util.Class")
local Observable			= require("aqua.util.Observable")
local StaticImage			= require("sphere.ui.StaticImage")
local Button				= require("sphere.ui.Button")
local ImageButton			= require("sphere.ui.ImageButton")
local PointGraph			= require("sphere.ui.PointGraph")
local ProgressBar			= require("sphere.ui.ProgressBar")
local InputImage			= require("sphere.ui.InputImage")
local ScoreDisplay			= require("sphere.ui.ScoreDisplay")
local StaticObject			= require("sphere.ui.StaticObject")
local Animation				= require("sphere.ui.Animation")
local NoteSkinMenu			= require("sphere.ui.NoteSkinMenu")
local ModifierMenu			= require("sphere.ui.ModifierMenu")
local KeyBindMenu			= require("sphere.ui.KeyBindMenu")
local NoteChartDataDisplay	= require("sphere.ui.NoteChartDataDisplay")
local ModifierDisplay		= require("sphere.ui.ModifierDisplay")
local SearchLine			= require("sphere.ui.SearchLine")
local JudgeDisplay			= require("sphere.ui.JudgeDisplay")
local ScreenManager			= require("sphere.screen.ScreenManager")

local GUI = Class:new()

GUI.construct = function(self)
	self.observable = Observable:new()
end

GUI.classes = {
	StaticImage = StaticImage,
	Button = Button,
	ImageButton = ImageButton,
	PointGraph = PointGraph,
	ProgressBar = ProgressBar,
	InputImage = InputImage,
	ScoreDisplay = ScoreDisplay,
	StaticObject = StaticObject,
	Animation = Animation,
	NoteChartDataDisplay = NoteChartDataDisplay,
	ModifierDisplay = ModifierDisplay,
	SearchLine = SearchLine,
	JudgeDisplay = JudgeDisplay
}
GUI.classes.__index = GUI.classes

GUI.functions = {
	["print"] = function(...) print(...) end,
	["NoteSkinMenu:show()"] = function() NoteSkinMenu:show() end,
	["ModifierMenu:show()"] = function() ModifierMenu:show() end,
	["KeyBindMenu:show()"] = function() KeyBindMenu:show() end
}
GUI.functions.__index = GUI.functions

GUI.load = function(self, path)
	local file = io.open(path, "r")
	local t = json.decode(file:read("*all"))
	file:close()

	self:loadTable(t)
end

GUI.loadTable = function(self, t)
	self.jsonData = t

	self.objects = {}

	for _, objectData in ipairs(self.jsonData) do
		local Object = self.classes[objectData.class]
		if Object then
			local object = Object:new()
			object.data = objectData
			object.gui = self
			object:loadGui()
			self.objects[#self.objects + 1] = object
		end
	end
end

GUI.update = function(self, dt)
	for _, object in ipairs(self.objects) do
		object:update(dt)
	end
end

GUI.unload = function(self)
	for _, object in ipairs(self.objects) do
		object:unload()
	end
end

GUI.reload = function(self)
	for _, object in ipairs(self.objects) do
		object:reload()
	end
end

GUI.receive = function(self, event)
	for _, object in ipairs(self.objects) do
		object:receive(event)
	end
end

return GUI
