local ShortLogicalNote	= require("sphere.models.RhythmModel.LogicEngine.ShortLogicalNote")
local LongLogicalNote	= require("sphere.models.RhythmModel.LogicEngine.LongLogicalNote")

local LogicalNoteFactory = {}

local notes = {
	ShortNote = {ShortLogicalNote, true, true},
	LongNoteStart = {LongLogicalNote, true, true},
	LaserNoteStart = {LongLogicalNote, true, true},
	LineNoteStart = {ShortLogicalNote},
	SoundNote = {ShortLogicalNote},
	ImageNote = {ShortLogicalNote},
}

LogicalNoteFactory.getNote = function(self, noteData)
	local classAndData = notes[noteData.noteType]
	if not classAndData then
		return
	end

	return classAndData[1]:new({
		noteData = noteData,
		isPlayable = classAndData[2],
		isScorable = classAndData[3],
	})
end

return LogicalNoteFactory
