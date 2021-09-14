local LogicalNote = require("sphere.models.RhythmModel.LogicEngine.LogicalNote")
local ShortLogicalNote = require("sphere.models.RhythmModel.LogicEngine.ShortLogicalNote")

local LongLogicalNote = LogicalNote:new()

LongLogicalNote.noteClass = "LongLogicalNote"

LongLogicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.endNoteData = self.noteData.endNoteData
	self.noteData = nil

	self.keyBind = self.startNoteData.inputType .. self.startNoteData.inputIndex

	LogicalNote.construct(self)

	self:switchState("clear")
end

LongLogicalNote.update = function(self)
	if self.ended then
		return
	end

	self.eventTime = self.eventTime or self.logicEngine.currentTime

	local startTimeState = self.scoreNote:getStartTimeState()
	local endTimeState = self.scoreNote:getEndTimeState()

	local numStates = #self.states
	if not self.autoplay then
		self:processTimeState(startTimeState, endTimeState)
	else
		self:processAuto()
	end

	if numStates ~= #self.states then
		return self:update()
	else
		self.eventTime = nil
	end
end

LongLogicalNote.processTimeState = function(self, startTimeState, endTimeState)
	local lastState = self:getLastState()

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
	if self:getLastState() == "startMissed" and nextNote:isReachable() then
		return self:next()
	end
end

LongLogicalNote.processAuto = function(self)
	local currentTime = self.logicEngine.exactCurrentTimeNoOffset
	if self.logicEngine.autoplay then
		currentTime = self.logicEngine.currentTime
	end

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

LongLogicalNote.receive = ShortLogicalNote.receive

return LongLogicalNote
