local Class					= require("aqua.util.Class")
local LogicalNoteFactory	= require("sphere.models.RhythmModel.LogicEngine.LogicalNoteFactory")

local NoteHandler = Class:new()

NoteHandler.load = function(self)
	self:loadNoteData()
end

NoteHandler.unload = function(self) end

NoteHandler.loadNoteData = function(self)
	self.noteData = {}
	local notesCount = self.logicEngine.notesCount

	local logicEngine = self.logicEngine
	local scoreEngine = self.logicEngine.rhythmModel.scoreEngine
	local timeEngine = self.logicEngine.rhythmModel.timeEngine
	for layerDataIndex in logicEngine.noteChart:getLayerDataIndexIterator() do
		local layerData = logicEngine.noteChart:requireLayerData(layerDataIndex)
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)

			if noteData.inputType == self.inputType and noteData.inputIndex == self.inputIndex then
				local logicalNote = LogicalNoteFactory:getNote(noteData)

				if logicalNote then
					logicalNote.noteHandler = self
					logicalNote.logicEngine = logicEngine
					logicalNote.scoreEngine = scoreEngine
					logicalNote.timeEngine = timeEngine
					if logicalNote.playable then
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
end

NoteHandler.updateRange = function(self)
	for i = self.startNoteIndex, #self.noteData do
		local logicalNote = self.noteData[i]
		if not logicalNote.ended then
			self.startNoteIndex = i
			break
		end
	end

	local eventTime = self.logicEngine:getEventTime()
	for i = self.endNoteIndex, #self.noteData do
		local logicalNote = self.noteData[i]
		if not logicalNote.ended and logicalNote:getNoteTime() >= eventTime then
			self.endNoteIndex = i
			break
		end
		if i == #self.noteData then
			self.endNoteIndex = #self.noteData
		end
	end
end

NoteHandler.getCurrentNote = function(self)
	self:updateRange()

	for i = self.startNoteIndex, self.endNoteIndex do
		local logicalNote = self.noteData[i]
		if not logicalNote.ended and logicalNote.state ~= "clear" then
			return logicalNote
		end
	end

	local timings = self.logicEngine.timings
	if not timings.nearest then
		local logicalNote = self.noteData[self.startNoteIndex]
		return not logicalNote.ended and logicalNote
	end

	local eventTime = self.logicEngine:getEventTime()

	local nearestIndex
	local nearestTime = math.huge
	for i = self.startNoteIndex, self.endNoteIndex do
		local logicalNote = self.noteData[i]
		local noteTime = logicalNote:getNoteTime()
		local time = math.abs(noteTime - eventTime)
		if not logicalNote.ended and time < nearestTime then
			nearestTime = time
			nearestIndex = i
		end
	end

	return self.noteData[nearestIndex]
end

NoteHandler.update = function(self)
	self:updateRange()
	for i = self.startNoteIndex, self.endNoteIndex do
		self.noteData[i]:update()
	end
end

NoteHandler.receive = function(self, event)
	self:update()
	local currentNote = self:getCurrentNote()
	if not currentNote then return end
	currentNote:receive(event)
end

return NoteHandler
