CloudburstEngine.GraphicalNote = createClass()
local GraphicalNote = CloudburstEngine.GraphicalNote

GraphicalNote.construct = function(self)
	self.id
		 = self.startNoteData.inputType
		.. self.startNoteData.inputIndex
		.. ":"
		.. self.noteType
	self.inputId
		 = self.startNoteData.inputType
		.. self.startNoteData.inputIndex
end

GraphicalNote.getCS = function(self)
	return self.engine.noteSkin:getCS(self)
end

GraphicalNote.updateLogicalNote = function(self)
	self.logicalNote = self.engine.sharedLogicalNoteData[self.startNoteData]
end

GraphicalNote.updateColor = function(self, currentColor, newColor)
	for index, value in ipairs(newColor) do
		if newColor[index] then
			currentColor[index] = newColor[index]
		end
	end
end

GraphicalNote.updateNext = function(self, index)
	local nextNote = self.noteDrawer.noteData[index]
	if nextNote and nextNote.activated then
		return nextNote:update()
	end
end
