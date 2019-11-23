local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local AutoKeySound			= require("sphere.screen.gameplay.ModifierManager.AutoKeySound")

local AutoKeySoundButton = CheckboxButton:new()

AutoKeySoundButton.construct = function(self)
	self.item.name = AutoKeySound.name
	
	CheckboxButton.construct(self)
end

AutoKeySoundButton.updateValue = function(self, value)
	AutoKeySound:setValue(value)
	ModifierManager.sequence:add(AutoKeySound)
end

return AutoKeySoundButton
