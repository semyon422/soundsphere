local ScoreNote = require("sphere.screen.gameplay.ScoreEngine.ScoreNote")

local LongScoreNote = ScoreNote:new()

LongScoreNote.noteType = "LongScoreNote"

LongScoreNote.construct = function(self)
	self.startNoteData = self.noteData
	self.endNoteData = self.noteData.endNoteData
	self.noteData = nil

	ScoreNote.construct(self)
end

LongScoreNote.getStartTimeState = function(self)
	local currentTime = self.logicalNote:getEventTime()
	local deltaTime = (currentTime - self.startNoteData.timePoint.absoluteTime) / math.abs(self.scoreEngine.timeRate)
	local config = self.scoreEngine.scoreSystem.scoreConfig.notes.LongScoreNote
	local pass = config.startPass
	local miss = config.startMiss

	if deltaTime >= pass[1] and deltaTime <= pass[2] then
		return "exactly"
	elseif deltaTime > pass[2] then
		return "late"
	elseif deltaTime >= miss[1] then
		return "early"
	end
	
	return "none"
end

LongScoreNote.getEndTimeState = function(self)
	local currentTime = self.logicalNote:getEventTime()
	local deltaTime = (currentTime - self.endNoteData.timePoint.absoluteTime) / math.abs(self.scoreEngine.timeRate)
	local config = self.scoreEngine.scoreSystem.scoreConfig.notes.LongScoreNote
	local pass = config.endPass
	local miss = config.endMiss

	if deltaTime >= pass[1] and deltaTime <= pass[2] then
		return "exactly"
	elseif deltaTime > pass[2] then
		return "late"
	elseif deltaTime >= miss[1] then
		return "early"
	end
	
	return "none"
end

LongScoreNote.isHere = function(self)
	local currentTime = self.logicalNote:getEventTime()
	return self.startNoteData.timePoint.absoluteTime <= currentTime
end

LongScoreNote.isReachable = function(self)
	local timeState = self:getStartTimeState()
	return timeState ~= "none" and timeState ~= "late"
end

LongScoreNote.update = function(self)
	local logicalNote = self.logicalNote
	local states = logicalNote.states
	local oldState, newState = states[self.currentStateIndex - 1], states[self.currentStateIndex]

	if newState then
		self:send({
			name = "ScoreNoteState",
			noteType = self.noteType,
			currentTime = newState.time,
			noteStartTime = self.startNoteData.timePoint.absoluteTime,
			noteEndTime = self.endNoteData.timePoint.absoluteTime,
			timeRate = self.scoreEngine.timeRate,
			scoreNotesCount = self.noteHandler.scoreNotesCount,
			oldState = oldState and oldState.name,
			newState = newState.name,
			minTime = self.scoreEngine.minTime,
			maxTime = self.scoreEngine.maxTime
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
