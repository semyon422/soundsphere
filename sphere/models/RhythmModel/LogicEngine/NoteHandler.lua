local Class					= require("Class")
local LogicalNoteFactory	= require("sphere.models.RhythmModel.LogicEngine.LogicalNoteFactory")

local NoteHandler = Class:new()

NoteHandler.load = function(self)
	self:loadNoteData()
end

NoteHandler.loadNoteData = function(self)
	self.notes = {}

	local logicEngine = self.logicEngine
	local notesCount = logicEngine.notesCount
	local rhythmModel = logicEngine.rhythmModel

	for _, noteData in ipairs(self.noteDatas) do
		local logicalNote = LogicalNoteFactory:getNote(noteData)
		if logicalNote then
			logicalNote.noteHandler = self
			logicalNote.logicEngine = logicEngine
			logicalNote.timeEngine = rhythmModel.timeEngine
			if logicalNote.isPlayable then
				notesCount[logicalNote.noteClass] = (notesCount[logicalNote.noteClass] or 0) + 1
			end
			table.insert(self.notes, logicalNote)

			logicEngine.sharedLogicalNotes[noteData] = logicalNote
		end
	end

	table.sort(self.notes, function(a, b)
		return a.startNoteData.timePoint < b.startNoteData.timePoint
	end)

	for index, logicalNote in ipairs(self.notes) do
		logicalNote.index = index
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

NoteHandler.receive = function(self, event)
	if self.logicEngine.autoplay then
		return
	end

	self:update()
	local note = self:getCurrentNote()
	if not note then return end

	local key = event and event[1]
	if key ~= self.keyBind then
		return
	end

	if event.name == "keypressed" then
		note.keyState = true
		self.logicEngine:playSound(note.startNoteData)
	elseif event.name == "keyreleased" then
		note.keyState = false
		self.logicEngine:playSound(note.endNoteData)
	end
	note:update()
end

return NoteHandler
