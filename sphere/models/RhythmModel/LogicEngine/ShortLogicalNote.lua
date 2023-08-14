local LogicalNote = require("sphere.models.RhythmModel.LogicEngine.LogicalNote")

local ShortLogicalNote = LogicalNote + {}

function ShortLogicalNote:new(noteData, isPlayable, isScorable)
	self.startNoteData = noteData
	self.isPlayable = isPlayable
	self.isScorable = isScorable
	self.noteData = nil
	self.state = "clear"
end

function ShortLogicalNote:update()
	if self.ended then
		return
	end

	if not self.isPlayable or self.logicEngine.autoplay then
		return self:processAuto()
	end

	local timeState = self:getTimeState()
	self:processTimeState(timeState)
end

function ShortLogicalNote:processTimeState(timeState)
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
function ShortLogicalNote:switchState(newState)
	local oldState = self.state
	self.state = newState

	if not self.isScorable then
		return
	end

	local timings = self.logicEngine.timings
	local timeRate = self.logicEngine:getTimeRate()
	local eventTime = self:getEventTime()
	local noteTime = self:getNoteTime()

	local lastTime = self:getLastTimeFromConfig(timings.ShortNote)
	local time = noteTime + lastTime * timeRate

	local currentTime = math.min(eventTime, time)
	local deltaTime = currentTime == time and lastTime or (currentTime - noteTime) / timeRate

	scoreEvent.noteIndex = self.index  -- required for tests
	scoreEvent.currentTime = currentTime
	scoreEvent.deltaTime = deltaTime
	scoreEvent.timeRate = timeRate
	scoreEvent.notesCount = self.logicEngine.notesCount
	scoreEvent.oldState = oldState
	scoreEvent.newState = newState
	self.logicEngine:sendScore(scoreEvent)

	if not self.pressedTime and newState == "passed" then
		self.pressedTime = currentTime
	end
	if self.pressedTime and newState ~= "passed" then
		self.pressedTime = nil
	end
end

function ShortLogicalNote:processAuto()
	if not self:isHere() then
		return
	end

	self.keyState = true
	self.logicEngine:playSound(self.startNoteData, not self.isPlayable)

	self.eventTime = self:getNoteTime()
	self:processTimeState("exactly")
	self.eventTime = nil
end

function ShortLogicalNote:getTimeState()
	local deltaTime = (self:getEventTime() - self:getNoteTime()) / self.logicEngine:getTimeRate()
	return self:getTimeStateFromConfig(self.logicEngine.timings.ShortNote, deltaTime)
end

function ShortLogicalNote:isReachable(_eventTime)
	local eventTime = self.eventTime
	self.eventTime = _eventTime
	local isReachable = self:getTimeState() ~= "too early"
	self.eventTime = eventTime
	return isReachable
end

return ShortLogicalNote
