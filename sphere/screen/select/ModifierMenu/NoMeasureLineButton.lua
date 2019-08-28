local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local NoMeasureLine		= require("sphere.screen.gameplay.ModifierManager.NoMeasureLine")

local NoMeasureLineButton = CheckboxButton:new()

NoMeasureLineButton.construct = function(self)
	self.item.name = NoMeasureLine.name
	
	CheckboxButton.construct(self)
end

NoMeasureLineButton.updateValue = function(self, value)
	NoMeasureLine:setValue(value)
	ModifierManager.sequence:add(NoMeasureLine)
end

return NoMeasureLineButton
