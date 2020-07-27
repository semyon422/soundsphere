local Class				= require("aqua.util.Class")
local ScoreNoteFactory	= require("sphere.models.RhythmModel.ScoreEngine.ScoreNoteFactory")

local NoteHandler = Class:new()

NoteHandler.load = function(self)
	self:loadNoteData()
end

NoteHandler.unload = function(self) end

NoteHandler.loadNoteData = function(self)
	self.scoreNotes = {}
	self.scoreNotesCount = {}
	local scoreNotesCount = self.scoreNotesCount
	
	local scoreEngine = self.scoreEngine
	for layerDataIndex in scoreEngine.noteChart:getLayerDataIndexIterator() do
		local layerData = scoreEngine.noteChart:requireLayerData(layerDataIndex)
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			local scoreNote = ScoreNoteFactory:getNote(noteData)
			
			if scoreNote then
				scoreNote.noteHandler = self
				scoreNote.scoreEngine = scoreEngine
				scoreNote.scoreSystem = scoreEngine.scoreSystem
				table.insert(self.scoreNotes, scoreNote)
				
				scoreEngine.sharedScoreNotes[noteData] = scoreNote

				local noteType = scoreNote.noteType
				scoreNotesCount[noteType] = (scoreNotesCount[noteType] or 0) + 1
			end
		end
	end

	self.currentNotes = {}
end

NoteHandler.update = function(self)
	local currentNotes = {}

	for currentNote in pairs(self.currentNotes) do
		currentNotes[currentNote] = true
	end

	for currentNote in pairs(currentNotes) do
		currentNote:update()
	end
end

NoteHandler.receive = function(self, event)
	if not self.currentNote then return end
	
	return self.currentNote:receive(event)
end

return NoteHandler
