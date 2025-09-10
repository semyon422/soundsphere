local class = require("class")
local TapInputNote = require("rizu.engine.input.notes.TapInputNote")
local HoldInputNote = require("rizu.engine.input.notes.HoldInputNote")

---@class rizu.InputNoteFactory
---@operator call: rizu.InputNoteFactory
local InputNoteFactory = class()

---@type {[notechart.NoteType]: rizu.InputNote?}
local notes = {
	tap = TapInputNote,
	hold = HoldInputNote,
	laser = nil,
	drumroll = nil,
	mine = nil,
	shade = nil,
	fake = nil,
	sample = nil,
	sprite = nil,
}

---@param input_info rizu.InputInfo
function InputNoteFactory:new(input_info)
	self.input_info = input_info
end

---@param note ncdk2.LinkedNote
---@return rizu.InputNote?
function InputNoteFactory:getNote(note)
	local Note = notes[note:getType()]
	if not Note then
		return
	end

	return Note(note, self.input_info)
end

return InputNoteFactory
