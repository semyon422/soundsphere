local class = require("class")
local table_util = require("table_util")

---@class rizu.NotesInput
---@operator call: rizu.NotesInput
local NotesInput = class()

---@param notes rizu.InputNote[]
function NotesInput:new(notes)
	self.notes = table_util.copy(notes)
	table.sort(self.notes, function(a, b)
		return a:getStartTime() < b:getStartTime()
	end)

	self.head_index = 1
	self.tail_index = 0
end

---@param time any
function NotesInput:updateRange(time)
	local notes = self.notes

	for i = self.head_index, #notes do
		local note = notes[i]
		if note:isActive() then
			self.head_index = i
			break
		end
		if i == #notes and not note:isActive() then
			self.head_index = #notes + 1
		end
	end

	for i = self.tail_index, #notes do
		local note = notes[i]
		if
			i == #notes or
			note and note:isActive() and note:getStartTime() >= time
		then
			self.tail_index = i
			break
		end
	end
end

function NotesInput:update()
	
end

function NotesInput:receive(event)
	
end

return NotesInput
