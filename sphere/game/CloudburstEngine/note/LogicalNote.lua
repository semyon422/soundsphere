local Class = require("aqua.util.Class")

local LogicalNote = Class:new()

LogicalNote.state = "clear"

LogicalNote.next = function(self)
	local nextNote = self.noteHandler.noteData[self.index + 1]
	if nextNote then
		self.noteHandler.currentNote = nextNote
		return self.noteHandler.currentNote:update()
	else
		self.ended = true
	end
end

LogicalNote.sendState = function(self)
	return self.engine.observable:send({
		name = "logicalNoteUpdated",
		logicalNote = self
	})
end

return LogicalNote
