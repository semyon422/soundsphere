local class = require("class")
local InputNoteFactory = require("rizu.engine.input.InputNoteFactory")

---@class rizu.InputEngine
---@operator call: rizu.InputEngine
local InputEngine = class()

InputEngine.nearest = false

---@param input_info rizu.InputInfo
function InputEngine:new(input_info)
	self.input_note_factory = InputNoteFactory(input_info)
	self:setNotes({})
end

---@param chart ncdk2.Chart
function InputEngine:load(chart)
	local input_note_factory = self.input_note_factory

	---@type rizu.InputNote[]
	local notes = {}
	for i, linked_note in ipairs(chart.notes:getLinkedNotes()) do
		notes[i] = input_note_factory:getNote(linked_note)
	end
	self:setNotes(notes)
end

---@param notes rizu.InputNote[]
function InputEngine:setNotes(notes)
	self.notes = notes
	table.sort(self.notes)

	self.note_index = 1

	---@type rizu.InputNote[]
	self.active_notes = {}
end

---@return integer
function InputEngine:getActiveNotesCount()
	return #self.active_notes
end

function InputEngine:update()
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
		if note:getPos() == "late" then
			table.remove(active_notes, i)
		end
	end
end

---@param event rizu.VirtualInputEvent
---@return integer
function InputEngine:getNotesMaxPriority(event)
	local priority = -math.huge

	for _, note in ipairs(self.active_notes) do
		if note:match(event) then
			priority = math.max(priority, note:getPriority())
		end
	end

	return priority
end

---@param event rizu.VirtualInputEvent
function InputEngine:receive(event)
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

	---@type rizu.InputNote?
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

return InputEngine
