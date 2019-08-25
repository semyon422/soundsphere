local Class = require("aqua.util.Class")

local LogicalNote = Class:new()

LogicalNote.state = "clear"

LogicalNote.getNext = function(self)
	return self.noteHandler.noteData[self.index + 1]
end

LogicalNote.next = function(self)
	self.ended = true
	local nextNote = self:getNext()
	if nextNote then
		self.noteHandler.currentNote = nextNote
		return self.noteHandler.currentNote:update()
	end
end

LogicalNote.isHere = function(self)
	return self.startNoteData.timePoint.absoluteTime <= self.engine.exactCurrentTime
end

LogicalNote.isReachable = function(self)
	local deltaTime = (self.engine.exactCurrentTime - self.startNoteData.timePoint.absoluteTime) / self.score.rate
	local timeState = self.score:getTimeState(deltaTime)
	return timeState ~= "none" and timeState ~= "late"
end

LogicalNote.update = function(self)
	return self.score:processNote(self)
end

return LogicalNote
