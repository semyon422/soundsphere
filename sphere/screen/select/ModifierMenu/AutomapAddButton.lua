local AddModifierButton	= require("sphere.screen.select.ModifierMenu.AddModifierButton")
local SequenceList		= require("sphere.screen.select.ModifierMenu.SequenceList")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local Automap			= require("sphere.screen.gameplay.ModifierManager.Automap")

local AutomapAddButton = AddModifierButton:new()

AutomapAddButton.construct = function(self)
	self.item.name = Automap.name
	
	AddModifierButton.construct(self)
end

AutomapAddButton.add = function(self)
	ModifierManager.sequence:add(Automap)
	SequenceList:reloadItems()
end

return AutomapAddButton
