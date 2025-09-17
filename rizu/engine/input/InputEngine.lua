local class = require("class")

---@class rizu.InputEngine
---@operator call: rizu.InputEngine
local InputEngine = class()

InputEngine.nearest = false

---@param active_notes rizu.LogicNote[]
function InputEngine:new(active_notes)
	self.active_notes = active_notes

	---@type {[rizu.VirtualInputEventId]: rizu.LogicNote}
	self.event_catches = {}
	---@type {[rizu.LogicNote]: rizu.VirtualInputEventId}
	self.catched_notes = {}

	---@type {[rizu.VirtualInputEventId]: any}
	self.event_values = {}
end

--- TODO: replace event with event.pos
---@param note rizu.LogicNote
---@param event rizu.VirtualInputEvent
---@return boolean
function InputEngine:match(note, event)
	return note:getColumn() == event.pos
end

---@param event rizu.VirtualInputEvent
---@return integer
function InputEngine:getNotesMaxPriority(event)
	local priority = -math.huge

	for _, note in ipairs(self.active_notes) do
		if self:match(note, event) then
			priority = math.max(priority, note:getPriority())
		end
	end

	return priority
end

---@param event rizu.VirtualInputEvent
---@param note rizu.LogicNote
---@return rizu.LogicNote?
---@return boolean? catched
function InputEngine:handle_catched_note(event, note)
	local event_values = self.event_values

	if event.value ~= nil then
		event_values[event.id] = event.value
	end

	local matched = self:match(note, event)
	if matched and event.value ~= nil then
		note:input(event.value or event_values[event.id])
		return note, not not event.value
	elseif not matched then
		note:input(false)
		return note, false
	end

	return note, true
end

---@param event rizu.VirtualInputEvent
---@return rizu.LogicNote?
---@return boolean? catched
function InputEngine:receive_catched(event)
	local active_notes = self.active_notes
	local catched_notes = self.catched_notes
	local event_values = self.event_values

	if not active_notes[1] then
		return
	end

	local catch_note = self.event_catches[event.id]
	for _, note in ipairs(active_notes) do
		if note == catch_note then
			return self:handle_catched_note(event, note)
		end
	end

	local value = event.value
	if not value then
		return
	end

	event_values[event.id] = event.value

	local priority = self:getNotesMaxPriority(event)

	if not self.nearest then
		for _, note in ipairs(active_notes) do
			if note:getPriority() == priority and self:match(note, event) and not catched_notes[note] then
				note:input(value)
				return note, not not event.value
			end
		end
		return
	end

	---@type rizu.LogicNote?
	local nearest_note
	local nearest_time = math.huge
	for _, note in ipairs(active_notes) do
		local time = math.abs(note:getDeltaTime())
		if note:getPriority() == priority and self:match(note, event) and not catched_notes[note] and time < nearest_time then
			nearest_time = time
			nearest_note = note
		end
	end

	if not nearest_note then
		return
	end

	nearest_note:input(value)
	return nearest_note, not not event.value
end

---@param event rizu.VirtualInputEvent
function InputEngine:receive(event)
	local note, catched = self:receive_catched(event)

	if not event.id then
		return
	end

	local _note = self.event_catches[event.id]
	if _note then
		self.catched_notes[_note] = nil
	end

	if not catched then
		self.event_catches[event.id] = nil
	elseif note and catched then
		self.event_catches[event.id] = note
		self.catched_notes[note] = event.id
	end
end

return InputEngine
