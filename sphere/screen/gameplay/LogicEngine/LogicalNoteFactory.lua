local ShortLogicalNote	= require("sphere.screen.gameplay.LogicEngine.ShortLogicalNote")
local LongLogicalNote	= require("sphere.screen.gameplay.LogicEngine.LongLogicalNote")

local LogicalNoteFactory = {}

LogicalNoteFactory.getNote = function(self, noteData)
	local logicalNote = {noteData = noteData}

	if noteData.noteType == "ShortNote" then
		return ShortLogicalNote:new(logicalNote)
	elseif noteData.noteType == "LongNoteStart" then
		return LongLogicalNote:new(logicalNote)
	else
		logicalNote.autoplay = true
		return ShortLogicalNote:new(logicalNote)
	end
end

return LogicalNoteFactory
