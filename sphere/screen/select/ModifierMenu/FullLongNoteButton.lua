local SliderButton		= require("sphere.screen.select.ModifierMenu.SliderButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local FullLongNote		= require("sphere.screen.gameplay.ModifierManager.FullLongNote")

local FullLongNoteButton = SliderButton:new()

FullLongNoteButton.construct = function(self)
	self.item.name = FullLongNote.name
	self.item.minValue = 0
	self.item.maxValue = 3
	self.item.minDisplayValue = 0
	self.item.maxDisplayValue = 3
	self.item.step = 1
	self.item.format = "%d"
	
	SliderButton.construct(self)
	
	self.slider.value = self.item.modifier:getValue().level
end

FullLongNoteButton.updateValue = function(self, value)
	self.item.modifier:setValue({level = value})
	
	SliderButton.updateValue(self, value)
end

FullLongNoteButton.removeModifier = function(self)
	ModifierManager.sequence:remove(self.item.modifier)
	
	local SequenceList = require("sphere.screen.select.ModifierMenu.SequenceList")
	SequenceList:reloadItems()
end

return FullLongNoteButton
