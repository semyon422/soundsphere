local ShortLogicalNote = require("sphere.models.RhythmModel.LogicEngine.ShortLogicalNote")
local LongLogicalNote = require("sphere.models.RhythmModel.LogicEngine.LongLogicalNote")

local LogicalNoteFactory = {}

local notes = {
	note = {ShortLogicalNote, true, true, true},
	hold = {LongLogicalNote, true, true, true},
	laser = {LongLogicalNote, true, true, true},
	drumroll = {LongLogicalNote, true, true, false},
	mine = {ShortLogicalNote},
	shade = {ShortLogicalNote},
	fake = {ShortLogicalNote},
	sample = {ShortLogicalNote},
	sprite = {ShortLogicalNote},
}


---@param note ncdk2.LinkedNote
---@return sphere.LogicalNote?
function LogicalNoteFactory:getNote(note)
	local classAndData = notes[note:getType()]
	if not classAndData then
		return
	end

	local isPlayable = classAndData[2]
	local isScorable = classAndData[3]
	local isInputMatchable = classAndData[4]
	return classAndData[1](note, isPlayable, isScorable, isInputMatchable)
end

return LogicalNoteFactory
