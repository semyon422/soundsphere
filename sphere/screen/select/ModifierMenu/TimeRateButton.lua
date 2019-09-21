local SliderButton		= require("sphere.screen.select.ModifierMenu.SliderButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local TimeRate			= require("sphere.screen.gameplay.ModifierManager.TimeRate")

local TimeRateButton = SliderButton:new()

TimeRateButton.construct = function(self)
	self.item.name = TimeRate.name
	self.item.minValue = 0.5
	self.item.maxValue = 2
	self.item.minDisplayValue = 0.5
	self.item.maxDisplayValue = 2
	self.item.step = 0.05
	self.item.format = "%0.2f"

	SliderButton.construct(self)
	
	self.slider.value = 1
end

TimeRateButton.updateValue = function(self, value)
	TimeRate:setValue(value)
	ModifierManager.sequence:add(TimeRate)
	
	SliderButton.updateValue(self, value)
end

TimeRateButton.removeModifier = function(self)
	self:updateValue(1)
	self.slider.value = TimeRate:getValue()
end

return TimeRateButton
