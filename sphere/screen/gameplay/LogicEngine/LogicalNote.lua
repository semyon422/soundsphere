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
	return self.startNoteData.timePoint.absoluteTime <= self.logicEngine.currentTime
end

LogicalNote.isReachable = function(self)
	local deltaTime = self.logicEngine.currentTime - self.startNoteData.timePoint.absoluteTime
	local timeState = self.score:getTimeState(deltaTime)
	return timeState ~= "none" and timeState ~= "late"
end

LogicalNote.update = function(self) end

LogicalNote.receive = function(self, event) end

LogicalNote.sendState = function(self, key)
	return self.logicEngine:send({
		name = "LogicalNoteState",
		note = self,
		key = key
	})
end

return LogicalNote
