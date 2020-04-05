local Class = require("aqua.util.Class")

local ScoreNote = Class:new()

ScoreNote.getMaxScore = function(self)
    return 0
end

ScoreNote.getTimeState = function(self)
    return "none"
end

ScoreNote.load = function(self)
    self.noteHandler.currentNotes[self] = true
end

ScoreNote.unload = function(self)
    self.noteHandler.currentNotes[self] = nil
end

ScoreNote.update = function(self) end

ScoreNote.isHere = function(self)
	return true
end

ScoreNote.isReachable = function(self)
	return true
end

return ScoreNote
