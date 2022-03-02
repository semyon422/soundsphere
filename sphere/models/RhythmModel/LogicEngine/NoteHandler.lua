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
					notesCount[logicalNote.noteClass] = (notesCount[logicalNote.noteClass] or 0) + 1
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
	self.currentNote = self.noteData[1]
	if not self.currentNote then return end
	self.currentNote:load()
end

NoteHandler.update = function(self)
	local currentNote = self.currentNote

	if not currentNote then return end
	if not currentNote.ended then currentNote:update() end
	if not currentNote.ended then return end

	self:switchNext()
	return self:update()
end

NoteHandler.switchNext = function(self)
	local currentNote = self.currentNote
	local nextNote = currentNote:getNext()
	if nextNote then
		currentNote:unload()
		nextNote:load()
		self.currentNote = nextNote
	else
		self.currentNote = nil
	end
	-- print("switch")
	f:write("switch\n")
end

NoteHandler.receive = function(self, event, count)
	count = count or 0
	local currentNote = self.currentNote

	print("NoteHandler.receive", currentNote, currentNote and currentNote.ended, self.inputIndex)
	if not currentNote then return end
	if currentNote.ended then
		self:switchNext()
		return self:receive(event, count + 1)
	end
	-- print("apply")
	f:write(("apply-%d\n"):format(count))
	f:write("event time ")
	f:write(event.time)
	f:write("\n")
	if currentNote:receive(event) then
		self:switchNext()
		return self:receive(event, count + 1)
	end
end

return NoteHandler
