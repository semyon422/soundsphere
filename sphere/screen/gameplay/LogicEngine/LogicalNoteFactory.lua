local ShortLogicalNote	= require("sphere.screen.gameplay.LogicEngine.ShortLogicalNote")
local LongLogicalNote	= require("sphere.screen.gameplay.LogicEngine.LongLogicalNote")
local LaserLogicalNote	= require("sphere.screen.gameplay.LogicEngine.LaserLogicalNote")

local LogicalNoteFactory = {}

LogicalNoteFactory.getNote = function(self, noteData)
	local logicalNote = {noteData = noteData}

	if noteData.noteType == "ShortNote" then
		return ShortLogicalNote:new(logicalNote)
	elseif noteData.noteType == "LongNoteStart" then
		return LongLogicalNote:new(logicalNote)
	elseif noteData.noteType == "LaserNoteStart" then
		return LaserLogicalNote:new(logicalNote)
	elseif noteData.noteType == "LineNoteStart" then
		logicalNote.autoplay = true
		return ShortLogicalNote:new(logicalNote)
	elseif noteData.noteType == "SoundNote" then
		logicalNote.autoplay = true
		return ShortLogicalNote:new(logicalNote)
	elseif noteData.noteType == "ImageNote" then
		logicalNote.autoplay = true
		return ShortLogicalNote:new(logicalNote)
	end
end

return LogicalNoteFactory
