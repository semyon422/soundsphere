local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

local ImageNote = GraphicalNote:new()

ImageNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil
end

ImageNote.update = function(self)
	return self:tryNext()
end

ImageNote.computeVisualTime = function(self) end

ImageNote.computeTimeState = function(self)
	self.timeState = self.timeState or {}
end

ImageNote.willDrawBeforeStart = function(self)
	local nextNote = self:getNext(1)

	if not nextNote then
		return false
	end

	return not nextNote:willDrawAfterEnd()
end

ImageNote.willDrawAfterEnd = function(self)
	local dt = self.timeEngine.currentVisualTime - self.startNoteData.timePoint.absoluteTime

	if dt < 0 then
		return true
	end
end

return ImageNote
