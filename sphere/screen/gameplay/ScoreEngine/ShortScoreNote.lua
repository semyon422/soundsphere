local ScoreNote = require("sphere.screen.gameplay.ScoreEngine.ScoreNote")

local ShortScoreNote = ScoreNote:new()

ShortScoreNote.noteType = "ShortScoreNote"

ShortScoreNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil

	ScoreNote.construct(self)
end

ShortScoreNote.getTimeState = function(self)
	local currentTime = self.logicalNote.eventTime or self.scoreEngine.currentTime
	local deltaTime = (currentTime - self.startNoteData.timePoint.absoluteTime) / self.scoreEngine.timeRate
	local config = self.scoreEngine.scoreSystem.scoreConfig.notes.ShortScoreNote
	local pass = config.pass
	local miss = config.miss

	if deltaTime >= pass[1] and deltaTime <= pass[2] then
		return "exactly"
	elseif deltaTime > pass[2] then
		return "late"
	elseif deltaTime >= miss[1] then
		return "early"
	end
	
	return "none"
end

ShortScoreNote.isHere = function(self)
	local currentTime = self.logicalNote.eventTime or self.scoreEngine.currentTime
	return self.startNoteData.timePoint.absoluteTime <= currentTime
end

ShortScoreNote.isReachable = function(self)
	local timeState = self:getTimeState()
	return timeState ~= "none" and timeState ~= "late"
end

ShortScoreNote.update = function(self)
	local logicalNote = self.logicalNote
	local states = logicalNote.states
	local oldState, newState = states[self.currentStateIndex - 1], states[self.currentStateIndex]

	if newState then
		local currentTime = newState.time or self.scoreEngine.currentTime
		self:send({
			name = "ScoreNoteState",
			noteType = self.noteType,
			currentTime = currentTime,
			noteTime = self.startNoteData.timePoint.absoluteTime,
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

return ShortScoreNote
