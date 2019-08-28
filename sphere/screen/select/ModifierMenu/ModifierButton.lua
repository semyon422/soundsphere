local aquafonts		= require("aqua.assets.fonts")
local TextFrame		= require("aqua.graphics.TextFrame")
local map			= require("aqua.math").map
local Class			= require("aqua.util.Class")
local spherefonts	= require("sphere.assets.fonts")
local Checkbox		= require("sphere.ui.Checkbox")
local CustomList	= require("sphere.ui.CustomList")
local Slider		= require("sphere.ui.Slider")

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

local ModifierButton = Class:new()

return ModifierButton
