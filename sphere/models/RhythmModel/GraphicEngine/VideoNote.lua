local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

local VideoNote = GraphicalNote:new()

VideoNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil
end

VideoNote.computeVisualTime = function(self) end

VideoNote.computeTimeState = function(self)
	self.timeState = self.timeState or {}
end

VideoNote.willDrawBeforeStart = function(self)
	local nextNote = self:getNext(1)

	if not nextNote then
		return false
	end

	return not nextNote:willDrawAfterEnd()
end

VideoNote.willDrawAfterEnd = function(self)
	local dt = self.graphicEngine.currentTime - self.startNoteData.timePoint.absoluteTime

	if dt < 0 then
		return true
	end
end

VideoNote.update = function(self, dt)
	return self:tryNext()
end

return VideoNote
