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

ScoreNote.update = function(self)
	if self.logicalNote.ended then
		return self:unload()
	end
end

ScoreNote.getTimeStateFromConfig = function(self, hit, miss, deltaTime)
	if deltaTime >= hit[1] and deltaTime <= hit[2] then
		return "exactly"
	elseif deltaTime >= miss[1] and deltaTime < hit[1] then
		return "early"
	elseif deltaTime > hit[2] and deltaTime <= miss[2] then
		return "late"
	elseif deltaTime < miss[1] then
		return "too early"
	elseif deltaTime > miss[2] then
		return "too late"
	end
end

ScoreNote.isHere = function(self)
	return true
end

ScoreNote.isReachable = function(self)
	return true
end

ScoreNote.send = function(self, event)
	self.scoreEngine:send(event)
	return self.scoreSystem:receive(event)
end

return ScoreNote
