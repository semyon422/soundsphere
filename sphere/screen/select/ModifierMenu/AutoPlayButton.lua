local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local AutoPlay			= require("sphere.screen.gameplay.ModifierManager.AutoPlay")

local AutoPlayButton = CheckboxButton:new()

AutoPlayButton.construct = function(self)
	self.item.name = AutoPlay.name
	
	CheckboxButton.construct(self)
end

AutoPlayButton.updateValue = function(self, value)
	AutoPlay:setValue(value)
	ModifierManager.sequence:add(AutoPlay)
end

return AutoPlayButton
