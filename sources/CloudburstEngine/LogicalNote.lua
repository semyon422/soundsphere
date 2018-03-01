CloudburstEngine.LogicalNote = createClass()
local LogicalNote = CloudburstEngine.LogicalNote

LogicalNote.state = "clear"

LogicalNote.next = function(self)
	local nextNote = self.noteHandler.noteData[self.index + 1]
	if nextNote then
		self.noteHandler.currentNote = nextNote
		self.noteHandler.currentNote:update()
	end
end