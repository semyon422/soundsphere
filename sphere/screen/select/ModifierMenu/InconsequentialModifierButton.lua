local AutoPlay		= require("sphere.screen.gameplay.ModifierManager.AutoPlay")
local AutoKeySound	= require("sphere.screen.gameplay.ModifierManager.AutoKeySound")
local Automap		= require("sphere.screen.gameplay.ModifierManager.Automap")
local ProMode		= require("sphere.screen.gameplay.ModifierManager.ProMode")
local SetInput		= require("sphere.screen.gameplay.ModifierManager.SetInput")
local TimeRate		= require("sphere.screen.gameplay.ModifierManager.TimeRate")
local Mirror		= require("sphere.screen.gameplay.ModifierManager.Mirror")
local NoLongNote	= require("sphere.screen.gameplay.ModifierManager.NoLongNote")
local NoMeasureLine	= require("sphere.screen.gameplay.ModifierManager.NoMeasureLine")
local CMod			= require("sphere.screen.gameplay.ModifierManager.CMod")
local FullLongNote	= require("sphere.screen.gameplay.ModifierManager.FullLongNote")
local ToOsu			= require("sphere.screen.gameplay.ModifierManager.ToOsu")

local AutoPlayButton		= require("sphere.screen.select.ModifierMenu.AutoPlayButton")
local AutoKeySoundButton	= require("sphere.screen.select.ModifierMenu.AutoKeySoundButton")
local AutomapAddButton		= require("sphere.screen.select.ModifierMenu.AutomapAddButton")
local ProModeButton			= require("sphere.screen.select.ModifierMenu.ProModeButton")
local SetInputButton		= require("sphere.screen.select.ModifierMenu.SetInputButton")
local TimeRateButton		= require("sphere.screen.select.ModifierMenu.TimeRateButton")
local MirrorButton			= require("sphere.screen.select.ModifierMenu.MirrorButton")
local NoLongNoteButton		= require("sphere.screen.select.ModifierMenu.NoLongNoteButton")
local NoMeasureLineButton	= require("sphere.screen.select.ModifierMenu.NoMeasureLineButton")
local CModButton			= require("sphere.screen.select.ModifierMenu.CModButton")
local FullLongNoteAddButton	= require("sphere.screen.select.ModifierMenu.FullLongNoteAddButton")
local ToOsuButton			= require("sphere.screen.select.ModifierMenu.ToOsuButton")

local class2button = {
	[AutoPlay] = AutoPlayButton,
	[AutoKeySound] = AutoKeySoundButton,
	[Automap] = AutomapAddButton,
	[ProMode] = ProModeButton,
	[SetInput] = SetInputButton,
	[TimeRate] = TimeRateButton,
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
