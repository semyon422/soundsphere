local class = require("class")
local table_util = require("table_util")

---@class rizu.InputNotesHandler
---@operator call: rizu.InputNotesHandler
local InputNotesHandler = class()

InputNotesHandler.nearest = false

---@param notes rizu.IInputNote[]
function InputNotesHandler:new(notes)
	self.notes = table_util.copy(notes)
	table.sort(self.notes)

	self.note_index = 1

	---@type rizu.IInputNote[]
	self.active_notes = {}
end

---@return integer
function InputNotesHandler:getActiveNotesCount()
	return #self.active_notes
end

function InputNotesHandler:update()
	local notes = self.notes
	local active_notes = self.active_notes

	for i = self.note_index, #notes do
		local note = notes[i]
		if note:isReachable() then
			self.note_index = i + 1
			if note:isActive() then
				table.insert(active_notes, note)
			end
		else
			break
		end
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

---@param event rizu.VirtualInputEvent
---@return integer
function InputNotesHandler:getNotesMaxPriority(event)
	local priority = -math.huge

	for _, note in ipairs(self.active_notes) do
		if note:match(event) then
			priority = math.max(priority, note:getPriority())
		end
	end

	return priority
end

---@param event rizu.VirtualInputEvent
function InputNotesHandler:receive(event)
	local active_notes = self.active_notes

	if not active_notes[1] then
		return
	end

	for _, note in ipairs(active_notes) do
		if note:catch(event) then
			note:receive(event)
			return
		end
	end

	local priority = self:getNotesMaxPriority(event)

	if not self.nearest then
		for _, note in ipairs(active_notes) do
			if note:getPriority() == priority and note:match(event) then
				note:receive(event)
				return
			end
		end
		return
	end

	---@type rizu.IInputNote?
	local nearest_note
	local nearest_time = math.huge
	for _, note in ipairs(active_notes) do
		local time = math.abs(note:getDeltaTime())
		if note:getPriority() == priority and note:match(event) and time < nearest_time then
			nearest_time = time
			nearest_note = note
		end
	end

	if nearest_note then
		nearest_note:receive(event)
	end
end

return InputNotesHandler
