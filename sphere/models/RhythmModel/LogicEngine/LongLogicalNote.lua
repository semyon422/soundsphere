local LogicalNote = require("sphere.models.RhythmModel.LogicEngine.LogicalNote")
local ShortLogicalNote = require("sphere.models.RhythmModel.LogicEngine.ShortLogicalNote")

local LongLogicalNote = LogicalNote:new()

LongLogicalNote.noteClass = "LongLogicalNote"

LongLogicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.endNoteData = self.noteData.endNoteData
	self.noteData = nil

	self.keyBind = self.startNoteData.inputType .. self.startNoteData.inputIndex
	self.state = "clear"
end

LongLogicalNote.update = function(self)
	if self.ended then
		return
	end

	if self.autoplay then
		return self:processAuto()
	end

	local startTimeState = self:getStartTimeState()
	local endTimeState = self:getEndTimeState()
	self:processTimeState(startTimeState, endTimeState)

	if self.ended then
		local nextNote = self:getNextPlayable()
		if nextNote then
			return nextNote:update()
		end
	end
end

LongLogicalNote.processTimeState = function(self, startTimeState, endTimeState)
	local lastState = self.state

	local keyState = self.keyState
	if keyState and startTimeState == "too early" then
		self.keyState = false
	elseif lastState == "clear" then
		if startTimeState == "too late" then
			self:switchState("startMissed")
			self.started = true
		elseif keyState then
			if startTimeState == "early" or startTimeState == "late" then
				self:switchState("startMissedPressed")
			elseif startTimeState == "exactly" then
				self:switchState("startPassedPressed")
			end
			self.started = true
		end
	elseif lastState == "startPassedPressed" then
		if endTimeState == "too late" then
			self:switchState("endMissed")
			return self:next()
		elseif not keyState then
			if endTimeState == "too early" then
				self:switchState("startMissed")
			elseif endTimeState == "early" or endTimeState == "late" then
				self:switchState("endMissed")
				return self:next()
			elseif endTimeState == "exactly" then
				self:switchState("endPassed")
				return self:next()
			end
		end
	elseif lastState == "startMissedPressed" then
		if not keyState then
			if endTimeState == "too early" then
				self:switchState("startMissed")
			elseif endTimeState == "early" or endTimeState == "late" then
				self:switchState("endMissed")
				return self:next()
			elseif endTimeState == "exactly" then
				self:switchState("endMissedPassed")
				return self:next()
			end
		elseif endTimeState == "too late" then
			self:switchState("endMissed")
			return self:next()
		end
	elseif lastState == "startMissed" then
		if keyState then
			self:switchState("startMissedPressed")
		elseif endTimeState == "too late" then
			self:switchState("endMissed")
			return self:next()
		end
	end

	local nextNote = self:getNextPlayable()
	if not nextNote then
		return
	end
	if self.state == "startMissed" and nextNote:isReachable() then
		return self:next()
	end
end

LongLogicalNote.switchState = function(self, newState)
	local oldState = self.state
	self.state = newState

	if self.autoplay then
		return
	end

	local config = self.logicEngine.timings.LongScoreNote
	local currentTime = math.min(self.eventTime or self.timeEngine.currentTime, self.endNoteData.timePoint.absoluteTime + self:getLastTimeFromConfig(config.endHit, config.endMiss) * math.abs(self.timeEngine.timeRate))
	-- if self.keyState then
	-- 	currentTime = self.eventTime or currentTime
	-- 	print(currentTime, self.endNoteData.timePoint.absoluteTime + self:getLastTimeFromConfig(config.endHit, config.endMiss) * math.abs(self.timeEngine.timeRate) * math.abs(self.timeEngine.timeRate))
	-- 	print(self:getStartTimeState(), self:getEndTimeState())
	-- 	currentTime = math.min(currentTime, self.endNoteData.timePoint.absoluteTime + self:getLastTimeFromConfig(config.endHit, config.endMiss) * math.abs(self.timeEngine.timeRate))
	-- 	-- assert(currentTime <= self.endNoteData.timePoint.absoluteTime + self:getLastTimeFromConfig(config.endHit, config.endMiss) * math.abs(self.timeEngine.timeRate) * math.abs(self.timeEngine.timeRate))
	-- end

	self:sendScore({
		name = "ScoreNoteState",
		noteType = "LongScoreNote",
		currentTime = currentTime,
		noteStartTime = self.startNoteData.timePoint.absoluteTime,
		noteEndTime = self.endNoteData.timePoint.absoluteTime,
		timeRate = self.scoreEngine.timeRate,
		notesCount = self.logicEngine.notesCount,
		oldState = oldState,
		newState = newState,
		minTime = self.scoreEngine.minTime,
		maxTime = self.scoreEngine.maxTime
	})
end

LongLogicalNote.processAuto = function(self)
	local currentTime = self.timeEngine.currentTime
	-- local currentTime = self.logicEngine.exactCurrentTimeNoOffset or self.logicEngine.currentTime
	-- if self.logicEngine.autoplay then
	-- 	currentTime = self.logicEngine.currentTime
	-- end

	local deltaStartTime = currentTime - self.startNoteData.timePoint.absoluteTime
	local deltaEndTime = currentTime - self.endNoteData.timePoint.absoluteTime

	local nextNote = self:getNextPlayable()
	if deltaStartTime >= 0 and not self.keyState then
		self.keyState = true
		self:sendState("keyState")

		self.eventTime = self.startNoteData.timePoint.absoluteTime
		self:processTimeState("exactly", "too early")
		self.eventTime = nil
	elseif deltaEndTime >= 0 and self.keyState or nextNote and nextNote:isHere() then
		self.keyState = false
		self:sendState("keyState")

		self.eventTime = self.endNoteData.timePoint.absoluteTime
		self:processTimeState("too late", "exactly")
		self.eventTime = nil
	end
end

LongLogicalNote.getStartTimeState = function(self)
	local currentTime = self:getEventTime()
	local deltaTime = (currentTime - self.startNoteData.timePoint.absoluteTime) / math.abs(self.timeEngine.timeRate)
	local config = self.logicEngine.timings.LongScoreNote
	return self:getTimeStateFromConfig(config.startHit, config.startMiss, deltaTime)
end

LongLogicalNote.getEndTimeState = function(self)
	local currentTime = self:getEventTime()
	local deltaTime = (currentTime - self.endNoteData.timePoint.absoluteTime) / math.abs(self.timeEngine.timeRate)
	local config = self.logicEngine.timings.LongScoreNote
	return self:getTimeStateFromConfig(config.endHit, config.endMiss, deltaTime)
end

LongLogicalNote.isReachable = function(self)
	return self:getStartTimeState() ~= "too early"
end

LongLogicalNote.receive = ShortLogicalNote.receive

return LongLogicalNote
