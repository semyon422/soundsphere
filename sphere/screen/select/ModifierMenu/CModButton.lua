local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local CMod				= require("sphere.screen.gameplay.ModifierManager.CMod")

local CModButton = CheckboxButton:new()

CModButton.construct = function(self)
	self.item.name = CMod.name
	
	CheckboxButton.construct(self)
end

CModButton.updateValue = function(self, value)
	CMod:setValue(value)
	ModifierManager.sequence:add(CMod)
end

return CModButton
