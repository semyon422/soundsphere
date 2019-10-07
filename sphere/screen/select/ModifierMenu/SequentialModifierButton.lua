local aquafonts		= require("aqua.assets.fonts")
local TextFrame		= require("aqua.graphics.TextFrame")
local map			= require("aqua.math").map
local Class			= require("aqua.util.Class")
local spherefonts	= require("sphere.assets.fonts")
local Checkbox		= require("sphere.ui.Checkbox")
local CustomList	= require("sphere.ui.CustomList")
local Slider		= require("sphere.ui.Slider")

local Automap		= require("sphere.screen.gameplay.ModifierManager.Automap")
local FullLongNote	= require("sphere.screen.gameplay.ModifierManager.FullLongNote")

local ModifierButton		= require("sphere.screen.select.ModifierMenu.ModifierButton")
local FullLongNoteButton	= require("sphere.screen.select.ModifierMenu.FullLongNoteButton")
local AutomapButton			= require("sphere.screen.select.ModifierMenu.AutomapButton")

local SequentialModifierButton = ModifierButton:new()

SequentialModifierButton.construct = function(self)
	if getmetatable(self.item.modifier) == FullLongNote then
		return FullLongNoteButton:new(self)
	elseif getmetatable(self.item.modifier) == Automap then
		return AutomapButton:new(self)
	end
	error()
end

return SequentialModifierButton
