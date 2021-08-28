local ScoreNote = require("sphere.models.RhythmModel.ScoreEngine.ScoreNote")

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
	local config = self.scoreEngine.scoreSystem.missWindows.LongScoreNote
	return self:getTimeStateFromConfig(config.startHit, config.startMiss, deltaTime)
end

LongScoreNote.getEndTimeState = function(self)
	local currentTime = self.logicalNote:getEventTime()
	local deltaTime = (currentTime - self.endNoteData.timePoint.absoluteTime) / math.abs(self.scoreEngine.timeRate)
	local config = self.scoreEngine.scoreSystem.missWindows.LongScoreNote
	return self:getTimeStateFromConfig(config.endHit, config.endMiss, deltaTime)
end

LongScoreNote.isHere = function(self)
	local currentTime = self.logicalNote:getEventTime()
	return self.startNoteData.timePoint.absoluteTime <= currentTime
end

LongScoreNote.isReachable = function(self)
	return self:getStartTimeState() ~= "too early"
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
