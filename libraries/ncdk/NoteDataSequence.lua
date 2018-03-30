ncdk.NoteDataSequence = {}
local NoteDataSequence = ncdk.NoteDataSequence

ncdk.NoteDataSequence_metatable = {}
local NoteDataSequence_metatable = ncdk.NoteDataSequence_metatable
NoteDataSequence_metatable.__index = NoteDataSequence

NoteDataSequence.new = function(self)
	local noteDataSequence = {}
	
	noteDataSequence.noteDataCount = 0
	
	setmetatable(noteDataSequence, NoteDataSequence_metatable)
	
	return noteDataSequence
end

NoteDataSequence.addNoteData = function(self, noteData)
	table.insert(self, noteData)
	self.noteDataCount = self.noteDataCount + 1
	
	if not (self.layerData.layerDataSequence.inputExisting[noteData.inputType] and
		self.layerData.layerDataSequence.inputExisting[noteData.inputType][noteData.inputIndex])
	then
		self.layerData.layerDataSequence.inputExisting[noteData.inputType] = self.layerData.layerDataSequence.inputExisting[noteData.inputType] or {}
		self.layerData.layerDataSequence.inputExisting[noteData.inputType][noteData.inputIndex] = true
	end
	
	self.layerData.layerDataSequence.noteChart.inputMode:setInput(noteData.inputType, noteData.inputIndex, true)
end

NoteDataSequence.getNoteData = function(self, noteDataIndex)
	return self[noteDataIndex]
end

NoteDataSequence.getNoteDataCount = function(self)
	return self.noteDataCount
end

NoteDataSequence.sort = function(self)
	table.sort(self, function(noteData1, noteData2)
		return noteData1.startTimePoint < noteData2.startTimePoint
	end)
end