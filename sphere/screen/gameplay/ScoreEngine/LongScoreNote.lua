local ScoreNote = require("sphere.screen.gameplay.ScoreEngine.ScoreNote")

local LongScoreNote = ScoreNote:new()

LongScoreNote.noteType = "LongNote"

LongScoreNote.construct = function(self)
	self.startNoteData = self.noteData
	self.endNoteData = self.noteData.endNoteData
	self.noteData = nil

	ScoreNote.construct(self)
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
	
	-- local startDeltaTime = (self.scoreEngine.currentTime - self.startNoteData.timePoint.absoluteTime) / self.scoreEngine.timeRate
	-- local endDeltaTime = (self.scoreEngine.currentTime - self.endNoteData.timePoint.absoluteTime) / self.scoreEngine.timeRate

	if newState then
		self:send({
			name = "ScoreNoteState",
			noteType = self.noteType,
			currentTime = self.scoreEngine.currentTime,
			noteStartTime = self.startNoteData.timePoint.absoluteTime,
			noteEndTime = self.endNoteData.timePoint.absoluteTime,
			timeRate = self.scoreEngine.timeRate,
			oldState = oldState,
			newState = newState
		})
	end

	self:nextStateIndex()

	if self:areNewStates() then
		return self:update()
	elseif self.logicalNote.ended then
		return self:unload()
	end
end

return LongScoreNote
