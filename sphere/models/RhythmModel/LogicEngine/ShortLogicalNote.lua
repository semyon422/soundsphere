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
		self.keyState = false
	elseif keyState and (timeState == "early" or timeState == "late") or timeState == "too late" then
		self:switchState("missed")
		return self:next()
	elseif keyState and timeState == "exactly" then
		self:switchState("passed")
		return self:next()
	end
end

ShortLogicalNote.switchState = function(self, newState)
	local oldState = self.state
	self.state = newState

	if not self.playable then
		return
	end

	local config = self.logicEngine.timings.ShortScoreNote
	local currentTime = math.min(self.eventTime or self.timeEngine.currentTime, self:getNoteTime() + self:getLastTimeFromConfig(config.hit, config.miss) * math.abs(self.timeEngine.timeRate))

	self:sendScore({
		name = "ScoreNoteState",
		noteType = "ShortScoreNote",
		currentTime = currentTime,
		-- currentTime = self:getEventTime(),
		noteTime = self:getNoteTime(),
		timeRate = self.scoreEngine.timeRate,
		notesCount = self.logicEngine.notesCount,
		oldState = oldState,
		newState = newState,
		minTime = self.scoreEngine.minTime,
		maxTime = self.scoreEngine.maxTime
	})
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
	local currentTime = self:getEventTime()
	local deltaTime = (currentTime - self:getNoteTime()) / math.abs(self.timeEngine.timeRate)
	local config = self.logicEngine.timings.ShortScoreNote
	return self:getTimeStateFromConfig(config.hit, config.miss, deltaTime)
end

ShortLogicalNote.isReachable = function(self, currentNote)
	local eventTime = self.eventTime
	self.eventTime = currentNote.eventTime
	local isReachable = self:getTimeState() ~= "too early"
	self.eventTime = eventTime
	return isReachable
end

ShortLogicalNote.receive = function(self, event, isRec)
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
