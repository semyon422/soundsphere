local AutoPlay		= require("sphere.screen.gameplay.ModifierManager.AutoPlay")
local ProMode		= require("sphere.screen.gameplay.ModifierManager.ProMode")
local SetInput		= require("sphere.screen.gameplay.ModifierManager.SetInput")
local Pitch			= require("sphere.screen.gameplay.ModifierManager.Pitch")
local Mirror		= require("sphere.screen.gameplay.ModifierManager.Mirror")
local NoLongNote	= require("sphere.screen.gameplay.ModifierManager.NoLongNote")
local NoMeasureLine	= require("sphere.screen.gameplay.ModifierManager.NoMeasureLine")
local CMod			= require("sphere.screen.gameplay.ModifierManager.CMod")
local FullLongNote	= require("sphere.screen.gameplay.ModifierManager.FullLongNote")
local ToOsu			= require("sphere.screen.gameplay.ModifierManager.ToOsu")

local AutoPlayButton		= require("sphere.screen.select.ModifierMenu.AutoPlayButton")
local ProModeButton			= require("sphere.screen.select.ModifierMenu.ProModeButton")
local SetInputButton		= require("sphere.screen.select.ModifierMenu.SetInputButton")
local PitchButton			= require("sphere.screen.select.ModifierMenu.PitchButton")
local MirrorButton			= require("sphere.screen.select.ModifierMenu.MirrorButton")
local NoLongNoteButton		= require("sphere.screen.select.ModifierMenu.NoLongNoteButton")
local NoMeasureLineButton	= require("sphere.screen.select.ModifierMenu.NoMeasureLineButton")
local CModButton			= require("sphere.screen.select.ModifierMenu.CModButton")
local FullLongNoteAddButton	= require("sphere.screen.select.ModifierMenu.FullLongNoteAddButton")
local ToOsuButton			= require("sphere.screen.select.ModifierMenu.ToOsuButton")

local class2button = {
	[AutoPlay] = AutoPlayButton,
	[ProMode] = ProModeButton,
	[SetInput] = SetInputButton,
	[Pitch] = PitchButton,
	[Mirror] = MirrorButton,
	[NoLongNote] = NoLongNoteButton,
	[NoMeasureLine] = NoMeasureLineButton,
	[CMod] = CModButton,
	[FullLongNote] = FullLongNoteAddButton,
	[ToOsu] = ToOsuButton,
}

local ModifierButton = require("sphere.screen.select.ModifierMenu.ModifierButton")

local InconsequentialModifierButton = ModifierButton:new()

InconsequentialModifierButton.construct = function(self)
	local Button = class2button[self.item.modifier]
	if Button then
		return Button:new(self)
	end
	error()
end

return InconsequentialModifierButton
