local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

---@class sphere.ImageNote: sphere.GraphicalNote
---@operator call: sphere.ImageNote
local ImageNote = GraphicalNote + {}

---@return boolean
function ImageNote:willDrawBeforeStart()
	local nextNote = self.nextNote
	return nextNote and not nextNote:willDrawAfterEnd()
end

---@return boolean
function ImageNote:willDrawAfterEnd()
	return self.graphicEngine:getCurrentTime() < self.startNoteData.timePoint.absoluteTime
end

return ImageNote
