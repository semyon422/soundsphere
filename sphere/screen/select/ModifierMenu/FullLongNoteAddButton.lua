local AddModifierButton	= require("sphere.screen.select.ModifierMenu.AddModifierButton")
local SequenceList		= require("sphere.screen.select.ModifierMenu.SequenceList")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local FullLongNote		= require("sphere.screen.gameplay.ModifierManager.FullLongNote")

local FullLongNoteAddButton = AddModifierButton:new()

FullLongNoteAddButton.construct = function(self)
	self.item.name = FullLongNote.name
	
	AddModifierButton.construct(self)
end

FullLongNoteAddButton.add = function(self)
	ModifierManager.sequence:add(FullLongNote)
	SequenceList:reloadItems()
end

return FullLongNoteAddButton
