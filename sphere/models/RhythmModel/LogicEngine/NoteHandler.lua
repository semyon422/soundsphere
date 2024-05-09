local class = require("class")
local LogicalNoteFactory = require("sphere.models.RhythmModel.LogicEngine.LogicalNoteFactory")

---@class sphere.NoteHandler
---@operator call: sphere.NoteHandler
local NoteHandler = class()

---@param logicEngine sphere.LogicEngine
function NoteHandler:new(logicEngine)
	self.logicEngine = logicEngine
	self.notes = {}

	---@type sphere.HandlerNote[]
	self.logicNotes = {}
end

function NoteHandler:load()
	---@type sphere.HandlerNote[]
	self.notes = {}
	local notes = self.notes

	local logicEngine = self.logicEngine

	for _, hnote in ipairs(self.logicNotes) do
		local _note = hnote._note
		local note = LogicalNoteFactory:getNote(_note)
		if note then
			hnote.note = note
			note.logicEngine = logicEngine
			table.insert(notes, hnote)
			logicEngine.sharedLogicalNotes[_note] = note
		end
	end

	table.sort(notes)

	for i, hnote in ipairs(notes) do
		hnote.note.index = i
		local next_hnote = notes[i + 1]
		hnote.note.nextNote = next_hnote and next_hnote.note
	end

	self.startNoteIndex = 1
	self.endNoteIndex = 1
end

function NoteHandler:updateRange()
	local notes = self.notes
	for i = self.startNoteIndex, #notes do
		local note = notes[i].note
		if not note.ended then
			self.startNoteIndex = i
			break
		end
		if i == #notes then
			self.startNoteIndex = #notes + 1
		end
	end

	local eventTime = self.logicEngine:getEventTime()
	for i = self.endNoteIndex, #notes do
		local note = notes[i].note
		if not note.ended and note.isPlayable and note:getNoteTime() >= eventTime then
			self.endNoteIndex = i
			break
		end
		if i == #notes then
			self.endNoteIndex = #notes
		end
	end
end

---return current isPlayable note
---@return sphere.HandlerNote?
function NoteHandler:getCurrentNote()
	local notes = self.notes
	self:updateRange()

	for i = self.startNoteIndex, self.endNoteIndex do
		local note = notes[i].note
		if not note.ended and note.state ~= "clear" then
			return notes[i]
		end
	end

	local timings = self.logicEngine.timings
	if not timings.nearest then
		for i = self.startNoteIndex, self.endNoteIndex do
			local note = notes[i].note
			if not note.ended and note.isPlayable then
				return notes[i]
			end
		end
	end

	local eventTime = self.logicEngine:getEventTime()

	local nearestIndex
	local nearestTime = math.huge
	for i = self.startNoteIndex, self.endNoteIndex do
		local note = notes[i].note
		local noteTime = note:getNoteTime()
		local time = math.abs(noteTime - eventTime)
		if not note.ended and note.isPlayable and time < nearestTime then
			nearestTime = time
			nearestIndex = i
		end
	end

	return notes[nearestIndex]
end

function NoteHandler:update()
	self:updateRange()
	for i = self.startNoteIndex, self.endNoteIndex do
		self.notes[i].note:update()
	end
end

---@param note sphere.LogicalNote
function NoteHandler:handlePromode(note)
	local isReachable = note:isReachable(self.logicEngine:getEventTime())
	if not note.ended and note.isPlayable and isReachable then
		note.isPlayable = false
	end
	note:update()
end

---@param state boolean
function NoteHandler:setKeyState(state, input)
	self:update()

	local hnote = self:getCurrentNote()
	if not hnote then return end

	local note = hnote.note

	if self.logicEngine.promode then
		self:handlePromode(note)
		return
	end

	note.keyState = state
	note.inputMatched = hnote.column == input

	local _note = state and note.startNote or note.endNote
	if _note then
		self.logicEngine:playSound(_note)
	end

	note:update()
end

return NoteHandler
