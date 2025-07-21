local ManiaTapInputNote = require("rizu.modes.mania.input.ManiaTapInputNote")
local ManiaHoldInputNote = require("rizu.modes.mania.input.ManiaHoldInputNote")

---@class rizu.InputNoteFactory
---@operator call: rizu.InputNoteFactory
local InputNoteFactory = {}

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

---@param timing_values sea.TimingValues
---@param time_info rizu.TimeInfo
function InputNoteFactory:new(timing_values, time_info)
	self.timing_values = timing_values
	self.time_info = time_info
end

---@param note ncdk2.LinkedNote
---@return rizu.IInputNote?
function InputNoteFactory:getNote(note)
	local Note = notes[note:getType()]
	if not Note then
		return
	end

	return Note(note, self.timing_values, self.time_info)
end

return InputNoteFactory
