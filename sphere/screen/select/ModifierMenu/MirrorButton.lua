local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local Mirror			= require("sphere.screen.gameplay.ModifierManager.Mirror")

local MirrorButton = CheckboxButton:new()

MirrorButton.construct = function(self)
	self.item.name = Mirror.name
	
	CheckboxButton.construct(self)
end

MirrorButton.updateValue = function(self, value)
	Mirror:setValue(value)
	ModifierManager.sequence:add(Mirror)
end

return MirrorButton
