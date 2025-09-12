local class = require("class")
local TapLogicNote = require("rizu.engine.logic.notes.TapLogicNote")
local HoldLogicNote = require("rizu.engine.logic.notes.HoldLogicNote")

---@class rizu.LogicNoteFactory
---@operator call: rizu.LogicNoteFactory
local LogicNoteFactory = class()

---@type {[notechart.NoteType]: rizu.LogicNote?}
local notes = {
	tap = TapLogicNote,
	hold = HoldLogicNote,
	laser = nil,
	drumroll = nil,
	mine = nil,
	shade = nil,
	fake = nil,
	sample = nil,
	sprite = nil,
}

---@param logic_info rizu.LogicInfo
function LogicNoteFactory:new(logic_info)
	self.logic_info = logic_info
end

---@param note ncdk2.LinkedNote
---@return rizu.LogicNote?
function LogicNoteFactory:getNote(note)
	local Note = notes[note:getType()]
	if not Note then
		return
	end

	return Note(note, self.logic_info)
end

return LogicNoteFactory
