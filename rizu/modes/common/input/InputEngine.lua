local class = require("class")
local InputNotesHandler = require("rizu.modes.common.input.InputNotesHandler")
local InputNoteFactory = require("rizu.modes.common.input.InputNoteFactory")

---@class rizu.InputEngine
---@operator call: rizu.InputDevice
local InputEngine = class()

---@param timing_values sea.TimingValues
---@param time_info rizu.TimeInfo
function InputEngine:new(timing_values, time_info)
	self.input_note_factory = InputNoteFactory(timing_values, time_info)
	self.input_notes_handler = InputNotesHandler({})
end

---@param chart ncdk2.Chart
function InputEngine:load(chart)
	local input_note_factory = self.input_note_factory

	---@type rizu.IInputNote[]
	local notes = {}

	for i, linked_note in ipairs(chart.notes:getLinkedNotes()) do
		notes[i] = input_note_factory:getNote(linked_note)
	end

	self.input_notes_handler = InputNotesHandler(notes)
end

function InputEngine:update()
	self.input_notes_handler:update()
end

---@param event rizu.VirtualInputEvent
function InputEngine:receive(event)
	self.input_notes_handler:receive(event)
end

return InputEngine
