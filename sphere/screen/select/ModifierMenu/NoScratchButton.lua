local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local NoScratch			= require("sphere.screen.gameplay.ModifierManager.NoScratch")

local NoScratchButton = CheckboxButton:new()

NoScratchButton.construct = function(self)
	self.item.name = NoScratch.name
	
	CheckboxButton.construct(self)
end

NoScratchButton.updateValue = function(self, value)
	NoScratch:setValue(value)
	ModifierManager.sequence:add(NoScratch)
end

return NoScratchButton
