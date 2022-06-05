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

	if self.autoplay or self.logicEngine.autoplay then
		return self:processAuto()
	end

	local startTimeState = self:getStartTimeState()
	local endTimeState = self:getEndTimeState()
	self:processTimeState(startTimeState, endTimeState)
end

LongLogicalNote.processTimeState = function(self, startTimeState, endTimeState)
	local lastState = self.state

	local keyState = self.keyState
	if keyState and startTimeState == "too early" then
		self:switchState("clear")
		self.keyState = false
	elseif lastState == "clear" then
		if startTimeState == "too late" then
			self:switchState("startMissed")
			self:tryNextNote()
			if self.state == "startMissed" and endTimeState == "too late" then
				self:switchState("endMissed")
				return self:next()
			end
		elseif keyState then
			if startTimeState == "early" or startTimeState == "late" then
				self:switchState("startMissedPressed")
			elseif startTimeState == "exactly" then
				self:switchState("startPassedPressed")
			end
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

	self:tryNextNote()
end

LongLogicalNote.tryNextNote = function(self)
	local nextNote = self:getNextPlayable()
	if not nextNote or self.state ~= "startMissed" then
		return
	end

	local eventTime = self:getEventTime()
	local timeRate = math.abs(self.timeEngine.timeRate)

	local lastTime = self:getLastTimeFromConfig(self.logicEngine.timings.LongNoteEnd)
	local time = self:getNoteTime("end") + lastTime * timeRate
	local currentTime = math.min(eventTime, time)

	if nextNote:isReachable(currentTime) then
		self:switchState("endMissed", nextNote)
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
	name = "NoteState",
	noteType = "LongNote",
}
LongLogicalNote.switchState = function(self, newState, reachableNote)
	local oldState = self.state
	self.state = newState

	if not self.playable then
		return
	end

	local timings = self.logicEngine.timings

	local currentTime, deltaTime
	local eventTime = self:getEventTime()
	local timeRate = math.abs(self.timeEngine.timeRate)
	if oldState == "clear" then
		local noteTime = self:getNoteTime("start")
		local lastTime = self:getLastTimeFromConfig(timings.LongNoteStart)
		local time = noteTime + lastTime * timeRate

		currentTime = math.min(eventTime, time)
		deltaTime = currentTime == time and lastTime or (currentTime - self:getNoteTime("start")) / timeRate
	else
		local lastTime = self:getLastTimeFromConfig(timings.LongNoteEnd)
		local time = self:getNoteTime("end") + lastTime * timeRate
		currentTime = math.min(eventTime, time)
		deltaTime = currentTime == time and lastTime or (currentTime - self:getNoteTime("end")) / timeRate
	end

	if reachableNote then
		currentTime = math.min(currentTime, reachableNote:getNoteTime("start") + self:getFirstTimeFromConfig(timings.ShortNote) * timeRate)
		deltaTime = self:getLastTimeFromConfig(timings.LongNoteEnd)
		-- currentTime = self:getNoteTime("end") + self:getLastTimeFromConfig(timings.LongNoteEnd) * timeRate
	end

	scoreEvent.noteIndex = self.index
	scoreEvent.currentTime = currentTime
	scoreEvent.deltaTime = deltaTime
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
	local deltaTime = (self:getEventTime() - self:getNoteTime("start")) / math.abs(self.timeEngine.timeRate)
	return self:getTimeStateFromConfig(self.logicEngine.timings.LongNoteStart, deltaTime)
end

LongLogicalNote.getEndTimeState = function(self)
	local deltaTime = (self:getEventTime() - self:getNoteTime("end")) / math.abs(self.timeEngine.timeRate)
	return self:getTimeStateFromConfig(self.logicEngine.timings.LongNoteEnd, deltaTime)
end

LongLogicalNote.isReachable = function(self, _eventTime)
	local eventTime = self.eventTime
	self.eventTime = _eventTime
	local isReachable = self:getStartTimeState() ~= "too early"
	self.eventTime = eventTime
	return isReachable
end

return LongLogicalNote
