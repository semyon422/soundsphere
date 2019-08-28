local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local ProMode			= require("sphere.screen.gameplay.ModifierManager.ProMode")

local ProModeButton = CheckboxButton:new()

ProModeButton.construct = function(self)
	self.item.name = ProMode.name
	
	CheckboxButton.construct(self)
end

ProModeButton.updateValue = function(self, value)
	ProMode:setValue(value)
	ModifierManager.sequence:add(ProMode)
end

return ProModeButton
