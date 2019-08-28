local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local ToOsu				= require("sphere.screen.gameplay.ModifierManager.ToOsu")

local ToOsuButton = CheckboxButton:new()

ToOsuButton.construct = function(self)
	self.item.name = ToOsu.name
	
	CheckboxButton.construct(self)
end

ToOsuButton.updateValue = function(self, value)
	ToOsu:setValue(value)
	ModifierManager.sequence:add(ToOsu)
end

return ToOsuButton
