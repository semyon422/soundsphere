local class = require("class")
local table_util = require("table_util")

---@class rizu.InputNotesHandler
---@operator call: rizu.InputNotesHandler
local InputNotesHandler = class()

InputNotesHandler.nearest = false

---@param notes rizu.InputNote[]
function InputNotesHandler:new(notes)
	self.notes = table_util.copy(notes)
	table.sort(self.notes, function(a, b)
		return a:getStartTime() < b:getStartTime()
	end)

	self.note_index = 1

	---@type rizu.InputNote[]
	self.active_notes = {}
end

---@return integer
function InputNotesHandler:getActiveNotesCount()
	return #self.active_notes
end

---@param time number
function InputNotesHandler:update(time)
	local notes = self.notes
	local active_notes = self.active_notes

	for i = self.note_index, #notes do
		local note = notes[i]
		if note:isReachable(time) then
			self.note_index = i + 1
			if note:isActive() then
				table.insert(active_notes, note)
			end
		else
			break
		end
	end

	for _, note in ipairs(active_notes) do
		note:update(time)
	end

	for i = #active_notes, 1, -1 do
		local note = active_notes[i]
		if not note:isActive() then
			table.remove(active_notes, i)
		end
	end
end

---@param event rizu.VirtualInputEvent
function InputNotesHandler:receive(event)
	local active_notes = self.active_notes

	for _, note in ipairs(active_notes) do
		if note:catch(event) then
			note:receive(event)
			return
		end
	end

	if not self.nearest then
		for _, note in ipairs(active_notes) do
			if note:match(event) then
				note:receive(event)
				return
			end
		end
		return
	end

	---@type rizu.InputNote?
	local nearest_note
	local nearest_time = math.huge
	for _, note in ipairs(active_notes) do
		local time = math.abs(note:getDeltaTime(event.time))
		if note:match(event) and time < nearest_time then
			nearest_time = time
			nearest_note = note
		end
	end

	if nearest_note then
		nearest_note:receive(event)
	end
end

return InputNotesHandler
