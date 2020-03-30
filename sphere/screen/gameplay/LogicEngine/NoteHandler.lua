local Class					= require("aqua.util.Class")
local LogicalNoteFactory	= require("sphere.screen.gameplay.LogicEngine.LogicalNoteFactory")

local NoteHandler = Class:new()

NoteHandler.load = function(self)
	self:loadNoteData()
	
	self.keyBind = self.inputType .. self.inputIndex
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
					logicalNote.score = logicEngine.score
					table.insert(self.noteData, logicalNote)
					
					logicEngine.sharedLogicalNoteData[noteData] = logicalNote
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
end

NoteHandler.update = function(self)
	if not self.currentNote then return end
	
	return self.currentNote:update()
end

NoteHandler.receive = function(self, event)
	if not self.currentNote then return end
	
	return self.currentNote:receive(event)
end

NoteHandler.send = function(self, event)
	return self.logicEngine.observable:send(event)
end

return NoteHandler
