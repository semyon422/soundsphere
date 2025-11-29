local class = require("class")
local table_util = require("table_util")
local InputNote = require("rizu.engine.input.notes.InputNote")

---@class rizu.ActiveInputNotes
---@operator call: rizu.ActiveInputNotes
local ActiveInputNotes = class()

---@param logic_notes rizu.LogicNote[]
function ActiveInputNotes:new(logic_notes)
	self.logic_notes = logic_notes

	---@type rizu.InputNote[]
	self.input_notes = {}

	---@type {[rizu.LogicNote]: rizu.InputNote}
	self.cache = {}
end

---@return boolean
function ActiveInputNotes:hasAny()
	return not not next(self.logic_notes)
end

---@private
function ActiveInputNotes:update()
	local input_notes = self.input_notes
	local cache = self.cache

	table_util.clear(input_notes)

	for i, logic_note in ipairs(self.logic_notes) do
		local input_note = cache[logic_note]
		if input_note then
			input_notes[i] = input_note
		else
			input_note = InputNote(logic_note)
			cache[logic_note] = input_note
		end
	end
end

function ActiveInputNotes:getNotes()
	self:update()
	return self.input_notes
end

return ActiveInputNotes
