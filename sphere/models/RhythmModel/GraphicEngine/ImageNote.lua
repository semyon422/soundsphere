local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

local ImageNote = GraphicalNote:new()

ImageNote.willDrawBeforeStart = function(self)
	local nextNote = self.nextNote
	return nextNote and not nextNote:willDrawAfterEnd()
end

ImageNote.willDrawAfterEnd = function(self)
	return self.graphicEngine:getCurrentTime() < self.startNoteData.timePoint.absoluteTime
end

return ImageNote
