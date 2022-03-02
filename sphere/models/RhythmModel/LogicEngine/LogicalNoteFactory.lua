local ShortLogicalNote	= require("sphere.models.RhythmModel.LogicEngine.ShortLogicalNote")
local LongLogicalNote	= require("sphere.models.RhythmModel.LogicEngine.LongLogicalNote")
local LaserLogicalNote	= require("sphere.models.RhythmModel.LogicEngine.LaserLogicalNote")

local LogicalNoteFactory = {}

LogicalNoteFactory.getNote = function(self, noteData)
	local logicalNote = {noteData = noteData}

	if noteData.noteType == "ShortNote" then
		logicalNote.scorable = true
		return ShortLogicalNote:new(logicalNote)
	elseif noteData.noteType == "LongNoteStart" then
		logicalNote.scorable = true
		return LongLogicalNote:new(logicalNote)
	elseif noteData.noteType == "LaserNoteStart" then
		logicalNote.scorable = true
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
