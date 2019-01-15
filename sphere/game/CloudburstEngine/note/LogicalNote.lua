local Class = require("aqua.util.Class")

local LogicalNote = Class:new()

LogicalNote.state = "clear"

LogicalNote.next = function(self)
	self.ended = true
	local nextNote = self.noteHandler.noteData[self.index + 1]
	if nextNote then
		self.noteHandler.currentNote = nextNote
		return self.noteHandler.currentNote:update()
	end
end

LogicalNote.update = function(self)
	return self.score:processNote(self)
end

return LogicalNote
