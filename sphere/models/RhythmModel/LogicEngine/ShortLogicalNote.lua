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

	if self.autoplay then
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

	if not self.playable then
		return
	end

	local timings = self.logicEngine.timings
	local config = timings.ShortNote
	local timeRate = math.abs(self.timeEngine.timeRate)
	local eventTime = self:getEventTime()
	local noteTime = self:getNoteTime()

	local lastTime = self:getLastTimeFromConfig(config.hit, config.miss)
	local baseLastTime = lastTime
	local time = noteTime + lastTime * timeRate

	local nextNote = self:getNextPlayable()
	if timings.nearest and nextNote then
		local nextTime = nextNote:getNoteTime()
		lastTime = (nextTime - noteTime) / 2
		time = math.min(time, noteTime + lastTime)
	end

	local currentTime = math.min(eventTime, time)
	local deltaTime = currentTime == time and baseLastTime or (currentTime - noteTime) / timeRate

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
end

ShortLogicalNote.processAuto = function(self)
	if self:isHere() then
		self.keyState = true
		self:sendState("keyState")

		self.eventTime = self:getNoteTime()
		self:processTimeState("exactly")
		self.eventTime = nil
	end
end

ShortLogicalNote.getTimeState = function(self)
	local timings = self.logicEngine.timings
	local currentTime = self:getEventTime()
	local noteTime = self:getNoteTime()

	local nextNote = self:getNextPlayable()
	if timings.nearest and nextNote then
		local nextTime = nextNote:getNoteTime()
		if 2 * currentTime > nextTime + noteTime then  -- map(currentTime, noteTime, nextTime, 0, 1) > 0.5
			return "too late"
		end
	end

	local deltaTime = (currentTime - noteTime) / math.abs(self.timeEngine.timeRate)
	local config = timings.ShortNote

	return self:getTimeStateFromConfig(config.hit, config.miss, deltaTime)
end

ShortLogicalNote.isReachable = function(self, _eventTime)
	local eventTime = self.eventTime
	self.eventTime = _eventTime
	local isReachable = self:getTimeState() ~= "too early"
	self.eventTime = eventTime
	return isReachable
end

ShortLogicalNote.receive = function(self, event)
	if self.logicEngine.autoplay then
		return
	end

	if self.autoplay then
		local nextNote = self:getNextPlayable()
		if nextNote then
			return nextNote:receive(event)
		end
		return
	end

	local key = event and event[1]
	if key == self.keyBind then
		self.eventTime = event.time
		self:update()
		if self.ended then
			return true
		end
		if event.name == "keypressed" then
			self.keyState = true
		elseif event.name == "keyreleased" then
			self.keyState = false
		end
		self:sendState("keyState")
		self:update()
		self.eventTime = nil
	end
end

return ShortLogicalNote
