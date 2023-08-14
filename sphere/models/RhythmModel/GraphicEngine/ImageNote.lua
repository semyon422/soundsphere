local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

local ImageNote = GraphicalNote + {}

function ImageNote:willDrawBeforeStart()
	local nextNote = self.nextNote
	return nextNote and not nextNote:willDrawAfterEnd()
end

function ImageNote:willDrawAfterEnd()
	return self.graphicEngine:getCurrentTime() < self.startNoteData.timePoint.absoluteTime
end

return ImageNote
