local class = require("class")
local LogicalNoteFactory = require("sphere.models.RhythmModel.LogicEngine.LogicalNoteFactory")

---@class sphere.NoteHandler
---@operator call: sphere.NoteHandler
local NoteHandler = class()

function NoteHandler:load()
	self.notes = {}
	local notes = self.notes

	local logicEngine = self.logicEngine

	for _, noteData in ipairs(self.noteDatas) do
		local note = LogicalNoteFactory:getNote(noteData)
		if note then
			note.noteHandler = self
			note.logicEngine = logicEngine
			table.insert(notes, note)
			logicEngine.sharedLogicalNotes[noteData] = note
		end
	end

	-- sort by absoluteTime because time points can have different types
	table.sort(notes, function(a, b)
		return a.startNoteData.timePoint.absoluteTime < b.startNoteData.timePoint.absoluteTime
	end)

	for i, note in ipairs(notes) do
		note.index = i
	end

	self.startNoteIndex = 1
	self.endNoteIndex = 1
end

function NoteHandler:updateRange()
	local notes = self.notes
	for i = self.startNoteIndex, #notes do
		local note = notes[i]
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
		local note = notes[i]
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
---@return sphere.LogicalNote?
function NoteHandler:getCurrentNote()
	local notes = self.notes
	self:updateRange()

	for i = self.startNoteIndex, self.endNoteIndex do
		local note = notes[i]
		if not note.ended and note.state ~= "clear" then
			return note
		end
	end

	local timings = self.logicEngine.timings
	if not timings.nearest then
		for i = self.startNoteIndex, self.endNoteIndex do
			local note = notes[i]
			if not note.ended and note.isPlayable then
				return note
			end
		end
	end

	local eventTime = self.logicEngine:getEventTime()

	local nearestIndex
	local nearestTime = math.huge
	for i = self.startNoteIndex, self.endNoteIndex do
		local note = notes[i]
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
		self.notes[i]:update()
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
function NoteHandler:setKeyState(state)
	self:update()

	local note = self:getCurrentNote()
	if not note then return end

	if self.logicEngine.promode then
		self:handlePromode(note)
		return
	end

	note.keyState = state
	local noteData = state and note.startNoteData or note.endNoteData
	if noteData then
		self.logicEngine:playSound(noteData)
	end

	note:update()
end

return NoteHandler
