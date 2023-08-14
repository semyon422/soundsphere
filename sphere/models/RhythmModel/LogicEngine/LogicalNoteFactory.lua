local ShortLogicalNote = require("sphere.models.RhythmModel.LogicEngine.ShortLogicalNote")
local LongLogicalNote = require("sphere.models.RhythmModel.LogicEngine.LongLogicalNote")

local LogicalNoteFactory = {}

local notes = {
	ShortNote = {ShortLogicalNote, true, true},
	LongNoteStart = {LongLogicalNote, true, true},
	LaserNoteStart = {LongLogicalNote, true, true},
	LineNoteStart = {ShortLogicalNote},
	SoundNote = {ShortLogicalNote},
	ImageNote = {ShortLogicalNote},
}

function LogicalNoteFactory:getNote(noteData)
	local classAndData = notes[noteData.noteType]
	if not classAndData then
		return
	end

	local isPlayable = classAndData[2]
	local isScorable = classAndData[3]
	return classAndData[1](noteData, isPlayable, isScorable)
end

return LogicalNoteFactory
