local class = require("class")
local table_util = require("table_util")
local LogicNoteFactory = require("rizu.engine.logic.LogicNoteFactory")

---@class rizu.LogicEngine
---@operator call: rizu.LogicEngine
local LogicEngine = class()

---@param logic_info rizu.LogicInfo
function LogicEngine:new(logic_info)
	self.input_note_factory = LogicNoteFactory(logic_info)

	---@type rizu.LogicNote[]
	self.active_notes = {}

	self:setNotes({})
end

---@param chart ncdk2.Chart
function LogicEngine:load(chart)
	local input_note_factory = self.input_note_factory

	---@type rizu.LogicNote[]
	local notes = {}
	for i, linked_note in ipairs(chart.notes:getLinkedNotes()) do
		local note = input_note_factory:getNote(linked_note)
		table.insert(notes, note)
	end
	self:setNotes(notes)
end

---@param notes rizu.LogicNote[]
function LogicEngine:setNotes(notes)
	self.notes = notes
	table.sort(self.notes)

	self.note_index = 1

	table_util.clear(self.active_notes)
end

---@return integer
function LogicEngine:getActiveNotesCount()
	return #self.active_notes
end

---@return rizu.LogicNote[]
function LogicEngine:getActiveNotes()
	return self.active_notes
end

function LogicEngine:update()
	local notes = self.notes
	local active_notes = self.active_notes

	for i = self.note_index, #notes do
		local note = notes[i]
		if note:getPos() == "early" then
			break
		end
		self.note_index = i + 1
		table.insert(active_notes, note)
	end

	for _, note in ipairs(active_notes) do
		note:update()
	end

	for i = #active_notes, 1, -1 do
		local note = active_notes[i]
		if not note:isActive() then
			table.remove(active_notes, i)
		end
	end
end

return LogicEngine
