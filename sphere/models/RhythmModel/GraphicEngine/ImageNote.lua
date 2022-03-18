local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

local ImageNote = GraphicalNote:new()

ImageNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil
end

ImageNote.willDrawBeforeStart = function(self)
	local nextNote = self:getNext(1)
	return nextNote and not nextNote:willDrawAfterEnd()
end

ImageNote.willDrawAfterEnd = function(self)
	return self.timeEngine.currentVisualTime < self.startNoteData.timePoint.absoluteTime
end

return ImageNote
