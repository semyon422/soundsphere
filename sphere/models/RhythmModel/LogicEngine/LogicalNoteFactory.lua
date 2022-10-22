local ShortLogicalNote	= require("sphere.models.RhythmModel.LogicEngine.ShortLogicalNote")
local LongLogicalNote	= require("sphere.models.RhythmModel.LogicEngine.LongLogicalNote")

local LogicalNoteFactory = {}

LogicalNoteFactory.getNote = function(self, noteData)
	local logicalNote = {noteData = noteData}

	if noteData.noteType == "ShortNote" then
		logicalNote.isPlayable = true
		logicalNote.isScorable = true
		return ShortLogicalNote:new(logicalNote)
	elseif noteData.noteType == "LongNoteStart" then
		logicalNote.isPlayable = true
		logicalNote.isScorable = true
		return LongLogicalNote:new(logicalNote)
	elseif noteData.noteType == "LaserNoteStart" then
		logicalNote.isPlayable = true
		logicalNote.isScorable = true
		return LongLogicalNote:new(logicalNote)
	elseif noteData.noteType == "LineNoteStart" then
		return ShortLogicalNote:new(logicalNote)
	elseif noteData.noteType == "SoundNote" then
		return ShortLogicalNote:new(logicalNote)
	elseif noteData.noteType == "ImageNote" then
		return ShortLogicalNote:new(logicalNote)
	end
end

return LogicalNoteFactory
