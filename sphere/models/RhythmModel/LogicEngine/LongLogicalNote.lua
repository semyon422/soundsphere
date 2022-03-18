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

	-- if self.ended then
	-- 	local nextNote = self:getNextPlayable()
	-- 	if nextNote then
	-- 		return nextNote:update()
	-- 	end
	-- end
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
	if self.state == "startMissed" and (not nextNote or nextNote:isReachable(self)) then
		self:switchState("endMissed")
		return self:next()
	end
end

LongLogicalNote.getNoteTime = function(self, side)
	local offset = 0
	if self.playable then
		offset = self.timeEngine.inputOffset
	end
	if not side or side == "start" then
		return self.startNoteData.timePoint.absoluteTime + offset
	elseif side == "end" then
		return self.endNoteData.timePoint.absoluteTime + offset
	end
	error("Wrong side")
end

local scoreEvent = {
	name = "ScoreNoteState",
	noteType = "LongScoreNote",
}
LongLogicalNote.switchState = function(self, newState)
	local oldState = self.state
	self.state = newState

	if not self.playable then
		return
	end

	local config = self.logicEngine.timings.LongScoreNote

	local currentTime
	local eventTime = self.eventTime or self.timeEngine.currentTime
	local timeRate = math.abs(self.timeEngine.timeRate)
	if oldState == "clear" then
		currentTime = math.min(eventTime, self:getNoteTime("start") + self:getLastTimeFromConfig(config.startHit, config.startMiss) * timeRate)
	else
		currentTime = math.min(eventTime, self:getNoteTime("end") + self:getLastTimeFromConfig(config.endHit, config.endMiss) * timeRate)
	end


	scoreEvent.currentTime = currentTime
	scoreEvent.noteStartTime = self:getNoteTime("start")
	scoreEvent.noteEndTime = self:getNoteTime("end")
	scoreEvent.timeRate = self.timeEngine.timeRate
	scoreEvent.notesCount = self.logicEngine.notesCount
	scoreEvent.oldState = oldState
	scoreEvent.newState = newState
	scoreEvent.minTime = self.scoreEngine.minTime
	scoreEvent.maxTime = self.scoreEngine.maxTime
	self:sendScore(scoreEvent)
end

LongLogicalNote.processAuto = function(self)
	local currentTime = self.timeEngine.currentTime

	local deltaStartTime = currentTime - self:getNoteTime("start")
	local deltaEndTime = currentTime - self:getNoteTime("end")

	local nextNote = self:getNextPlayable()
	if deltaStartTime >= 0 and not self.keyState then
		self.keyState = true
		self:sendState("keyState")

		self.eventTime = self:getNoteTime("start")
		self:processTimeState("exactly", "too early")
		self.eventTime = nil
	end
	if deltaEndTime >= 0 and self.keyState or nextNote and nextNote:isHere() then
		self.keyState = false
		self:sendState("keyState")

		self.eventTime = self:getNoteTime("end")
		self:processTimeState("too late", "exactly")
		self.eventTime = nil
	end
end

LongLogicalNote.getStartTimeState = function(self)
	local currentTime = self:getEventTime()
	local deltaTime = (currentTime - self:getNoteTime("start")) / math.abs(self.timeEngine.timeRate)
	local config = self.logicEngine.timings.LongScoreNote
	return self:getTimeStateFromConfig(config.startHit, config.startMiss, deltaTime)
end

LongLogicalNote.getEndTimeState = function(self)
	local currentTime = self:getEventTime()
	local deltaTime = (currentTime - self:getNoteTime("end")) / math.abs(self.timeEngine.timeRate)
	local config = self.logicEngine.timings.LongScoreNote
	return self:getTimeStateFromConfig(config.endHit, config.endMiss, deltaTime)
end

LongLogicalNote.isReachable = function(self, currentNote)
	local eventTime = self.eventTime
	self.eventTime = currentNote:getEventTime()
	local isReachable = self:getStartTimeState() ~= "too early"
	self.eventTime = eventTime
	return isReachable
end

LongLogicalNote.receive = ShortLogicalNote.receive

return LongLogicalNote
