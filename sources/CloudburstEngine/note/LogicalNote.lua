CloudburstEngine.LogicalNote = createClass()
local LogicalNote = CloudburstEngine.LogicalNote

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
	return self.engine.observable:sendEvent({
		name = "logicalNoteUpdated",
		logicalNote = self
	})
end