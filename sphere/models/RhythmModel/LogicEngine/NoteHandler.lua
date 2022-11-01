local Class					= require("Class")
local LogicalNoteFactory	= require("sphere.models.RhythmModel.LogicEngine.LogicalNoteFactory")

local NoteHandler = Class:new()

NoteHandler.load = function(self)
	self:loadNoteData()
end

NoteHandler.loadNoteData = function(self)
	self.noteData = {}

	local logicEngine = self.logicEngine
	local notesCount = logicEngine.notesCount
	local rhythmModel = logicEngine.rhythmModel
	for _, layerData in logicEngine.noteChart:getLayerDataIterator() do
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)

			if noteData.inputType == self.inputType and noteData.inputIndex == self.inputIndex then
				local logicalNote = LogicalNoteFactory:getNote(noteData)

				if logicalNote then
					logicalNote.noteHandler = self
					logicalNote.logicEngine = logicEngine
					logicalNote.scoreEngine = rhythmModel.scoreEngine
					logicalNote.timeEngine = rhythmModel.timeEngine
					logicalNote.audioEngine = rhythmModel.audioEngine
					if logicalNote.isPlayable then
						notesCount[logicalNote.noteClass] = (notesCount[logicalNote.noteClass] or 0) + 1
					end
					table.insert(self.noteData, logicalNote)

					logicEngine.sharedLogicalNotes[noteData] = logicalNote
				end
			end
		end
	end

	table.sort(self.noteData, function(a, b)
		return a.startNoteData.timePoint < b.startNoteData.timePoint
	end)

	for index, logicalNote in ipairs(self.noteData) do
		logicalNote.index = index
	end

	self.startNoteIndex = 1
	self.endNoteIndex = 1

	self.keyBind = self.inputType .. self.inputIndex
end

NoteHandler.updateRange = function(self)
	local noteData = self.noteData
	for i = self.startNoteIndex, #noteData do
		local logicalNote = noteData[i]
		if not logicalNote.ended then
			self.startNoteIndex = i
			break
		end
		if i == #noteData then
			self.startNoteIndex = #noteData + 1
		end
	end

	local eventTime = self.logicEngine:getEventTime()
	for i = self.endNoteIndex, #noteData do
		local logicalNote = noteData[i]
		if not logicalNote.ended and logicalNote:getNoteTime() >= eventTime then
			self.endNoteIndex = i
			break
		end
		if i == #noteData then
			self.endNoteIndex = #noteData
		end
	end
end

NoteHandler.getCurrentNote = function(self)
	local noteData = self.noteData
	self:updateRange()

	for i = self.startNoteIndex, self.endNoteIndex do
		local note = noteData[i]
		if not note.ended and note.state ~= "clear" then
			return note
		end
	end

	local timings = self.logicEngine.timings
	if not timings.nearest then
		local note
		for i = self.startNoteIndex, self.endNoteIndex do
			local _note = noteData[i]
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
		local note = noteData[i]
		local noteTime = note:getNoteTime()
		local time = math.abs(noteTime - eventTime)
		if not note.ended and note.isPlayable and time < nearestTime then
			nearestTime = time
			nearestIndex = i
		end
	end

	return noteData[nearestIndex]
end

NoteHandler.update = function(self)
	self:updateRange()
	for i = self.startNoteIndex, self.endNoteIndex do
		self.noteData[i]:update()
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
		note:playSound(note.startNoteData)
	elseif event.name == "keyreleased" then
		note.keyState = false
		note:playSound(note.endNoteData)
	end
	note:update()
end

return NoteHandler
