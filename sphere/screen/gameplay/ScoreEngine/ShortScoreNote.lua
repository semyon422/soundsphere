local ScoreNote = require("sphere.screen.gameplay.ScoreEngine.ScoreNote")

local ShortScoreNote = ScoreNote:new()

ShortScoreNote.noteType = "ShortScoreNote"

ShortScoreNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil

	ScoreNote.construct(self)
end

ShortScoreNote.getTimeState = function(self)
	local deltaTime = (self.scoreEngine.currentTime - self.startNoteData.timePoint.absoluteTime) / self.scoreEngine.timeRate
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
	return self.startNoteData.timePoint.absoluteTime <= self.scoreEngine.currentTime
end

ShortScoreNote.isReachable = function(self)
	local timeState = self:getTimeState()
	return timeState ~= "none" and timeState ~= "late"
end

ShortScoreNote.update = function(self)
	local logicalNote = self.logicalNote
	local states = logicalNote.states
	local oldState, newState = states[self.currentStateIndex - 1], states[self.currentStateIndex]

	-- local deltaTime = (self.scoreEngine.currentTime - self.startNoteData.timePoint.absoluteTime) / self.scoreEngine.timeRate

	if newState then
		local currentTime = self.scoreEngine.currentTime
		if logicalNote.autoplayStart then
			currentTime = self.startNoteData.timePoint.absoluteTime
			logicalNote.autoplayStart = false
		end
		self:send({
			name = "ScoreNoteState",
			noteType = self.noteType,
			currentTime = currentTime,
			noteTime = self.startNoteData.timePoint.absoluteTime,
			timeRate = self.scoreEngine.timeRate,
			scoreNotesCount = self.noteHandler.scoreNotesCount,
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

return ShortScoreNote
