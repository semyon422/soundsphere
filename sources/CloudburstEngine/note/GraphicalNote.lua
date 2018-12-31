CloudburstEngine.GraphicalNote = createClass()
local GraphicalNote = CloudburstEngine.GraphicalNote

GraphicalNote.getCS = function(self)
	return self.engine.noteSkin:getCS(self)
end

GraphicalNote.updateLogicalNote = function(self)
	self.logicalNote = self.engine.sharedLogicalNoteData[self.startNoteData]
end

GraphicalNote.updateColour = function(self, currentColour, newColour)
	for index, value in ipairs(newColour) do
		if newColour[index] then
			currentColour[index] = newColour[index]
		end
	end
end

GraphicalNote.updateNext = function(self, index)
	local nextNote = self.noteDrawer.noteData[index]
	if nextNote and nextNote.activated then
		return nextNote:update()
	end
end
