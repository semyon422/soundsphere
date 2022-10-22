local LogicalNote = require("sphere.models.RhythmModel.LogicEngine.LogicalNote")

local ShortLogicalNote = LogicalNote:new()

ShortLogicalNote.noteClass = "ShortLogicalNote"

ShortLogicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil

	self.keyBind = self.startNoteData.inputType .. self.startNoteData.inputIndex
	self.state = "clear"
end

ShortLogicalNote.update = function(self)
	if self.ended then
		return
	end

	if not self.isPlayable or self.logicEngine.autoplay then
		return self:processAuto()
	end

	local timeState = self:getTimeState()
	self:processTimeState(timeState)
end

ShortLogicalNote.processTimeState = function(self, timeState)
	local keyState = self.keyState
	if keyState and timeState == "too early" then
		self:switchState("clear")
		self.keyState = false
	elseif keyState and (timeState == "early" or timeState == "late") or timeState == "too late" then
		self:switchState("missed")
		return self:next()
	elseif keyState and timeState == "exactly" then
		self:switchState("passed")
		return self:next()
	end
end

local scoreEvent = {
	name = "NoteState",
	noteType = "ShortNote",
}
ShortLogicalNote.switchState = function(self, newState)
	local oldState = self.state
	self.state = newState

	if not self.isScorable then
		return
	end

	local timings = self.logicEngine.timings
	local timeRate = math.abs(self.timeEngine.timeRate)
	local eventTime = self:getEventTime()
	local noteTime = self:getNoteTime()

	local lastTime = self:getLastTimeFromConfig(timings.ShortNote)
	local time = noteTime + lastTime * timeRate

	local currentTime = math.min(eventTime, time)
	local deltaTime = currentTime == time and lastTime or (currentTime - noteTime) / timeRate

	scoreEvent.noteIndex = self.index
	scoreEvent.currentTime = currentTime
	scoreEvent.deltaTime = deltaTime
	scoreEvent.noteTime = self:getNoteTime()
	scoreEvent.timeRate = self.timeEngine.timeRate
	scoreEvent.notesCount = self.logicEngine.notesCount
	scoreEvent.oldState = oldState
	scoreEvent.newState = newState
	scoreEvent.minTime = self.scoreEngine.minTime
	scoreEvent.maxTime = self.scoreEngine.maxTime
	self:sendScore(scoreEvent)

	if not self.pressedTime and newState == "passed" then
		self.pressedTime = currentTime
	end
	if self.pressedTime and newState ~= "passed" then
		self.pressedTime = nil
	end
end

ShortLogicalNote.processAuto = function(self)
	if not self:isHere() then
		return
	end

	self.keyState = true
	self:playSound(self.startNoteData)

	self.eventTime = self:getNoteTime()
	self:processTimeState("exactly")
	self.eventTime = nil
end

ShortLogicalNote.getTimeState = function(self)
	local deltaTime = (self:getEventTime() - self:getNoteTime()) / math.abs(self.timeEngine.timeRate)
	return self:getTimeStateFromConfig(self.logicEngine.timings.ShortNote, deltaTime)
end

ShortLogicalNote.isReachable = function(self, _eventTime)
	local eventTime = self.eventTime
	self.eventTime = _eventTime
	local isReachable = self:getTimeState() ~= "too early"
	self.eventTime = eventTime
	return isReachable
end

return ShortLogicalNote
