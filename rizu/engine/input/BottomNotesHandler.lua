local class = require("class")

---@class rizu.BottomNotesHandler
---@operator call: rizu.BottomNotesHandler
local BottomNotesHandler = class()

---@param active_notes rizu.LogicNote[]
---@param match fun(note: rizu.LogicNote, pos: any): boolean
function BottomNotesHandler:new(active_notes, match)
	self.active_notes = active_notes

	---@type {[rizu.VirtualInputEventId]: any}
	self.event_values = {}
	---@type {[rizu.VirtualInputEventId]: any}
	self.event_positions = {}

	self._match = match
end

---@param note rizu.LogicNote
---@param pos any
---@return boolean
function BottomNotesHandler:match(note, pos)
	return self._match(note, pos)
end

function BottomNotesHandler:update()
	local active_notes = self.active_notes
	local event_values = self.event_values
	local event_positions = self.event_positions

	for _, note in ipairs(active_notes) do
		if note.is_bottom then
			---@type any
			local matching_value = false
			for id, value in pairs(event_values) do
				if value then
					local pos = event_positions[id]
					if self:match(note, pos) then
						matching_value = value
						break
					end
				end
			end
			note:input(matching_value)
		end
	end
end

---@param event rizu.VirtualInputEvent
function BottomNotesHandler:receive(event)
	local event_values = self.event_values
	local event_positions = self.event_positions

	local value = event.value
	if value ~= nil then
		event_values[event.id] = value
	end

	event_positions[event.id] = event.pos

	if event.value == false then
		event_values[event.id] = nil
		event_positions[event.id] = nil
	end
end

return BottomNotesHandler
