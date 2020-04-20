local Class = require("aqua.util.Class")

local ScoreNote = Class:new()

ScoreNote.noteType = "ScoreNote"

ScoreNote.construct = function(self)
	self.currentStateIndex = 1
end

ScoreNote.getTimeState = function(self)
	return "none"
end

ScoreNote.nextStateIndex = function(self)
	self.currentStateIndex = math.min(self.currentStateIndex + 1, #self.logicalNote.states + 1)
end

ScoreNote.areNewStates = function(self)
	return self.currentStateIndex <= #self.logicalNote.states
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

ScoreNote.send = function(self, event)
	return self.scoreSystem:receive(event)
end

return ScoreNote
