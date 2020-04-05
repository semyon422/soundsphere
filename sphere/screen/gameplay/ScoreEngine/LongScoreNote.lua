local ScoreNote = require("sphere.screen.gameplay.ScoreEngine.ScoreNote")

local LongScoreNote = ScoreNote:new()

LongScoreNote.construct = function(self)
	self.startNoteData = self.noteData
	self.endNoteData = self.noteData.endNoteData
	self.noteData = nil
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
    local oldState, newState = states[#states - 1], states[#states]
    
	if oldState == "clear" and newState == "startPassedPressed" then
		-- self.combo = self.combo + 1
	elseif (
		(oldState == "clear" or oldState == "startPassedPressed") and (
			newState == "startMissed" or
			newState == "startMissedPressed" or
			newState == "endMissed"
		)
	) then
		-- self.combo = 0
	end
    
    -- return self:unload()
end

return LongScoreNote
