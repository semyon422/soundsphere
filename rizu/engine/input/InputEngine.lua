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
end

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
---@return rizu.LogicNote?
---@return boolean? catched
function InputEngine:receive_catched(event)
	local active_notes = self.active_notes
	local catched_notes = self.catched_notes

	if not active_notes[1] then
		return
	end

	local catch_note = self.event_catches[event.id]
	for _, note in ipairs(active_notes) do
		if note == catch_note then
			local catched = note:input(event.value)
			return note, catched
		end
	end

	local priority = self:getNotesMaxPriority(event)

	if not self.nearest then
		for _, note in ipairs(active_notes) do
			if note:getPriority() == priority and self:match(note, event) and not catched_notes[note] then
				local catched = note:input(event.value)
				return note, catched
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

	local catched = nearest_note:input(event.value)
	return nearest_note, catched
end

---@param event rizu.VirtualInputEvent
function InputEngine:receive(event)
	local note, catched = self:receive_catched(event)

	if not event.id then
		return
	end

	if not catched then
		note = self.event_catches[event.id]
		self.event_catches[event.id] = nil
		if note then
			self.catched_notes[note] = nil
		end
	elseif note and catched then
		self.event_catches[event.id] = note
		self.catched_notes[note] = event.id
	end
end

return InputEngine
