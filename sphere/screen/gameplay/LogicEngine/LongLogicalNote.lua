local LogicalNote = require("sphere.screen.gameplay.LogicEngine.LogicalNote")

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
	end
end

LongLogicalNote.processTimeState = function(self, startTimeState, endTimeState)
	local lastState = self:getLastState()

	if self.keyState and startTimeState == "none" then
		self.keyState = false
	elseif lastState == "clear" then
		if startTimeState == "late" then
			self:switchState("startMissed")
			self.started = true
		elseif self.keyState then
			if startTimeState == "early" then
				self:switchState("startMissedPressed")
			elseif startTimeState == "exactly" then
				self:switchState("startPassedPressed")
			end
			self.started = true
		end
	elseif lastState == "startPassedPressed" then
		if not self.keyState then
			if endTimeState == "none" then
				self:switchState("startMissed")
			elseif endTimeState == "exactly" then
				self:switchState("endPassed")
				return self:next()
			end
		elseif endTimeState == "late" then
			self:switchState("endMissed")
			return self:next()
		end
	elseif lastState == "startMissedPressed" then
		if not self.keyState then
			if endTimeState == "exactly" then
				self:switchState("endMissedPassed")
				return self:next()
			else
				self:switchState("startMissed")
			end
		elseif endTimeState == "late" then
			self:switchState("endMissed")
			return self:next()
		end
	elseif lastState == "startMissed" then
		if self.keyState then
			self:switchState("startMissedPressed")
		elseif endTimeState == "late" then
			self:switchState("endMissed")
			return self:next()
		end
	end
	
	local nextNote = self:getNext()
	if nextNote and self:getLastState() == "startMissed" and nextNote:isReachable() then
		return self:next()
	end
end

LongLogicalNote.processAuto = function(self)
	local deltaStartTime = self.startNoteData.timePoint.absoluteTime - self.logicEngine.currentTime
	local deltaEndTime = self.endNoteData.timePoint.absoluteTime - self.logicEngine.currentTime
	
	local nextNote = self:getNext()
	if deltaStartTime <= 0 and not self.keyState then
		self.keyState = true
		self:sendState("keyState")
		
		self.autoplayStart = true
		self:processTimeState("exactly", "none")
	elseif deltaEndTime <= 0 and self.keyState or nextNote and nextNote:isHere() then
		self.keyState = false
		self:sendState("keyState")
		
		self.autoplayEnd = true
		self:processTimeState("none", "exactly")
	end
end

LongLogicalNote.receive = function(self, event)
	if self.autoplay then
		return
	end

	local key = event.args and event.args[1]
	if key == self.keyBind then
		if event.name == "keypressed" then
			self.keyState = true
			return self:sendState("keyState")
		elseif event.name == "keyreleased" then
			self.keyState = false
			return self:sendState("keyState")
		end
	end
end

return LongLogicalNote
