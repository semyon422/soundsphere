local CheckboxButton	= require("sphere.screen.select.ModifierMenu.CheckboxButton")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")
local NoLongNote		= require("sphere.screen.gameplay.ModifierManager.NoLongNote")

local NoLongNoteButton = CheckboxButton:new()

NoLongNoteButton.construct = function(self)
	self.item.name = NoLongNote.name
	
	CheckboxButton.construct(self)
end

NoLongNoteButton.updateValue = function(self, value)
	NoLongNote:setValue(value)
	ModifierManager.sequence:add(NoLongNote)
end

return NoLongNoteButton
