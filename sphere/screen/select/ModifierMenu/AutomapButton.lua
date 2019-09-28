local SliderButton		= require("sphere.screen.select.ModifierMenu.SliderButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local Automap			= require("sphere.screen.gameplay.ModifierManager.Automap")

local AutomapButton = SliderButton:new()

AutomapButton.construct = function(self)
	self.item.name = Automap.name
	self.item.minValue = 4
	self.item.maxValue = 10
	self.item.minDisplayValue = 4
	self.item.maxDisplayValue = 10
	self.item.step = 1
	self.item.format = "%d"
	
	SliderButton.construct(self)
	
	self.slider.value = self.item.modifier:getValue().level
end

AutomapButton.updateValue = function(self, value)
	self.item.modifier:setValue({level = value})
	
	SliderButton.updateValue(self, value)
end

AutomapButton.removeModifier = function(self)
	ModifierManager.sequence:remove(self.item.modifier)
	
	local SequenceList = require("sphere.screen.select.ModifierMenu.SequenceList")
	SequenceList:reloadItems()
end

return AutomapButton
