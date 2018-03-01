CloudburstEngine.GraphicalNote = createClass()
local GraphicalNote = CloudburstEngine.GraphicalNote

GraphicalNote.getCS = function(self)
	return self.engine.noteSkin:getCS(self)
end

GraphicalNote.getLogicalNote = function(self)
	return self.engine.sharedLogicalNoteData[self.noteData]
end

GraphicalNote.updateColour = function(self, currentColour, newColour)
	for index, value in ipairs(newColour) do
		if newColour[index] then
			currentColour[index] = newColour[index]
		end
	end
end
