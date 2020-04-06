local Class					= require("aqua.util.Class")
local LogicalNoteFactory	= require("sphere.screen.gameplay.LogicEngine.LogicalNoteFactory")

local NoteHandler = Class:new()

NoteHandler.load = function(self)
	self:loadNoteData()
end

NoteHandler.unload = function(self) end

NoteHandler.loadNoteData = function(self)
	self.noteData = {}
	
	local logicEngine = self.logicEngine
	for layerDataIndex in logicEngine.noteChart:getLayerDataIndexIterator() do
		local layerData = logicEngine.noteChart:requireLayerData(layerDataIndex)
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.inputType == self.inputType and noteData.inputIndex == self.inputIndex then
				local logicalNote = LogicalNoteFactory:getNote(noteData)
				
				if logicalNote then
					logicalNote.noteHandler = self
					logicalNote.logicEngine = logicEngine
					-- logicalNote.score = logicEngine.score
					logicalNote.scoreNote = self.logicEngine:getScoreNote(noteData)
					logicalNote.scoreNote.logicalNote = logicalNote
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
	self.currentNote:load()
end

NoteHandler.update = function(self)
	local currentNote = self.currentNote

	if not currentNote then
		return
	end
	
	currentNote:update()

	if not currentNote.ended then
		return
	end
	
	local nextNote = currentNote:getNext()
	if nextNote then
		currentNote:unload()
		nextNote:load()
		self.currentNote = nextNote
		return self:update()
	end
end

NoteHandler.receive = function(self, event)
	if not self.currentNote then return end
	
	return self.currentNote:receive(event)
end

return NoteHandler
