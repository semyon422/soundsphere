local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local Pitch				= require("sphere.screen.gameplay.ModifierManager.Pitch")

local PitchButton = CheckboxButton:new()

PitchButton.construct = function(self)
	self.item.name = Pitch.name
	
	CheckboxButton.construct(self)
end

PitchButton.updateValue = function(self, value)
	Pitch:setValue(value)
	ModifierManager.sequence:add(Pitch)
end

return PitchButton
