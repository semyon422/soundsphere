local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local WindUp			= require("sphere.screen.gameplay.ModifierManager.WindUp")

local WindUpButton = CheckboxButton:new()

WindUpButton.construct = function(self)
	self.item.name = WindUp.name
	
	CheckboxButton.construct(self)
end

WindUpButton.updateValue = function(self, value)
	WindUp:setValue(value)
	ModifierManager.sequence:add(WindUp)
end

return WindUpButton
