local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local SetInput			= require("sphere.screen.gameplay.ModifierManager.SetInput")

local SetInputButton = CheckboxButton:new()

SetInputButton.construct = function(self)
	self.item.name = SetInput.name
	
	CheckboxButton.construct(self)
end

SetInputButton.updateValue = function(self, value)
	SetInput:setValue(value)
	ModifierManager.sequence:add(SetInput)
end

return SetInputButton
