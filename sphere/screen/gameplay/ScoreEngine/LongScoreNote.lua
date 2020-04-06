local ScoreNote = require("sphere.screen.gameplay.ScoreEngine.ScoreNote")

local LongScoreNote = ScoreNote:new()

LongScoreNote.construct = function(self)
	self.startNoteData = self.noteData
	self.endNoteData = self.noteData.endNoteData
	self.noteData = nil

	ScoreNote.construct(self)
end

LongScoreNote.getMaxScore = function(self)
    if not self.logicalNote.autoplay then
        return 1
    end

    return 0
end

LongScoreNote.passEdge = 0.120
LongScoreNote.missEdge = 0.160
LongScoreNote.getStartTimeState = function(self)
	local deltaTime = (self.scoreEngine.currentTime - self.startNoteData.timePoint.absoluteTime) / self.scoreEngine.timeRate

	if math.abs(deltaTime) <= self.passEdge then
		return "exactly"
	elseif deltaTime > self.passEdge then
		return "late"
	elseif deltaTime >= -self.missEdge then
		return "early"
	end
	
	return "none"
end

LongScoreNote.getEndTimeState = function(self)
	local deltaTime = (self.scoreEngine.currentTime - self.endNoteData.timePoint.absoluteTime) / self.scoreEngine.timeRate

	if math.abs(deltaTime) <= self.passEdge then
		return "exactly"
	elseif deltaTime > self.passEdge then
		return "late"
	elseif deltaTime >= -self.missEdge then
		return "early"
	end
	
	return "none"
end

LongScoreNote.isHere = function(self)
	return self.startNoteData.timePoint.absoluteTime <= self.scoreEngine.currentTime
end

LongScoreNote.isReachable = function(self)
	local timeState = self:getStartTimeState()
	return timeState ~= "none" and timeState ~= "late"
end

LongScoreNote.update = function(self)
    local states = self.logicalNote.states
	local oldState, newState = states[self.currentStateIndex - 1], states[self.currentStateIndex]
	
	if oldState == "clear" then
		if newState == "startPassedPressed" then
		elseif newState == "startMissed" then
		elseif newState == "startMissedPressed" then
		end
	elseif oldState == "startPassedPressed" then
		if newState == "startMissed" then
		elseif newState == "endMissed" then
			return self:unload()
		elseif newState == "endPassed" then
			return self:unload()
		end
	elseif oldState == "startMissedPressed" then
		if newState == "endMissedPassed" then
			return self:unload()
		elseif newState == "startMissed" then
		elseif newState == "endMissed" then
			return self:unload()
		end
	elseif oldState == "startMissed" then
		if newState == "startMissedPressed" then
		elseif newState == "endMissed" then
			return self:unload()
		end
	end

	self:nextStateIndex()
end

return LongScoreNote
