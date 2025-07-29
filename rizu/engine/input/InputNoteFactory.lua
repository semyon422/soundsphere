local class = require("class")
local ManiaTapInputNote = require("rizu.engine.input.mania.ManiaTapInputNote")
local ManiaHoldInputNote = require("rizu.engine.input.mania.ManiaHoldInputNote")

---@class rizu.InputNoteFactory
---@operator call: rizu.InputNoteFactory
local InputNoteFactory = class()

---@type {[notechart.NoteType]: rizu.IInputNote?}
local notes = {
	tap = ManiaTapInputNote,
	hold = ManiaHoldInputNote,
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
---@return rizu.IInputNote?
function InputNoteFactory:getNote(note)
	local Note = notes[note:getType()]
	if not Note then
		return
	end

	return Note(note, self.input_info)
end

return InputNoteFactory
