local Class					= require("Class")
local LogicalNoteFactory	= require("sphere.models.RhythmModel.LogicEngine.LogicalNoteFactory")

local NoteHandler = Class:new()

NoteHandler.load = function(self)
	self.notes = {}
	local notes = self.notes

	local logicEngine = self.logicEngine
	local notesCount = logicEngine.notesCount

	for _, noteData in ipairs(self.noteDatas) do
		local note = LogicalNoteFactory:getNote(noteData)
		if note then
			note.noteHandler = self
			note.logicEngine = logicEngine
			if note.isPlayable then
				notesCount[note.noteClass] = (notesCount[note.noteClass] or 0) + 1
			end
			table.insert(notes, note)
			logicEngine.sharedLogicalNotes[noteData] = note
		end
	end

	table.sort(notes, function(a, b)
		return a.startNoteData.timePoint < b.startNoteData.timePoint
	end)

	for i, note in ipairs(notes) do
		note.index = i
	end

	self.startNoteIndex = 1
	self.endNoteIndex = 1
end

NoteHandler.updateRange = function(self)
	local notes = self.notes
	for i = self.startNoteIndex, #notes do
		local logicalNote = notes[i]
		if not logicalNote.ended then
			self.startNoteIndex = i
			break
		end
		if i == #notes then
			self.startNoteIndex = #notes + 1
		end
	end

	local eventTime = self.logicEngine:getEventTime()
	for i = self.endNoteIndex, #notes do
		local logicalNote = notes[i]
		if not logicalNote.ended and logicalNote:getNoteTime() >= eventTime then
			self.endNoteIndex = i
			break
		end
		if i == #notes then
			self.endNoteIndex = #notes
		end
	end
end

NoteHandler.getCurrentNote = function(self)
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
		local note
		for i = self.startNoteIndex, self.endNoteIndex do
			local _note = notes[i]
			if not _note.ended and _note.isPlayable then
				note = _note
				break
			end
		end
		return note
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

NoteHandler.update = function(self)
	self:updateRange()
	for i = self.startNoteIndex, self.endNoteIndex do
		self.notes[i]:update()
	end
end

NoteHandler.handlePromode = function(self, note)
	local isReachable = note:isReachable(self.logicEngine:getEventTime())
	if not note.ended and note.isPlayable and isReachable then
		note.isPlayable = false
	end
	note:update()
end

NoteHandler.setKeyState = function(self, state)
	self:update()

	local note = self:getCurrentNote()
	if not note then return end

	if self.logicEngine.promode then
		return self:handlePromode(note)
	end

	note.keyState = state
	if state then
		self.logicEngine:playSound(note.startNoteData)
	else
		self.logicEngine:playSound(note.endNoteData)
	end

	note:update()
end

return NoteHandler
