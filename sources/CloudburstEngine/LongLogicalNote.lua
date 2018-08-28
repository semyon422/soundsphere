CloudburstEngine.LongLogicalNote = createClass(CloudburstEngine.LogicalNote)
local LongLogicalNote = CloudburstEngine.LongLogicalNote


LongLogicalNote.update = function(self)
	if self.state == "endPassed" or self.state == "endMissed" or self.state == "endMissedPassed" then
		return
	end
	
	local deltaStartTime = self.startNoteData.timePoint:getAbsoluteTime() - self.engine.currentTime
	local deltaEndTime = self.endNoteData.timePoint:getAbsoluteTime() - self.engine.currentTime
	
	local startTimeState = self.engine:getTimeState(deltaStartTime)
	local endTimeState = self.engine:getTimeState(deltaEndTime)
	
	self.oldState = self.state
	if self.keyState and timeState == "none" then
		self.keyState = false
	elseif self.state == "clear" then
		if startTimeState == "late" then
			self.state = "startMissed"
			self:sendState()
		elseif self.keyState then
			if startTimeState == "early" then
				self.state = "startMissedPressed"
				self:sendState()
			elseif startTimeState == "exactly" then
				self.state = "startPassedPressed"
				self:sendState()
			end
		end
	elseif self.state == "startPassedPressed" then
		self.fakeStartTime = self.engine.currentTime
		if not self.keyState then
			if endTimeState == "none" then
				self.state = "startMissed"
				self:sendState()
			elseif endTimeState == "exactly" then
				self.state = "endPassed"
				self:sendState()
				self:next()
			end
		elseif endTimeState == "late" then
			self.state = "endMissed"
			self:sendState()
			self:next()
		end
	elseif self.state == "startMissedPressed" then
		if not self.keyState then
			if endTimeState == "exactly" then
				self.state = "endMissedPassed"
				self:sendState()
				self:next()
			else
				self.state = "startMissed"
			end
		elseif endTimeState == "late" then
			self.state = "endMissed"
			self:sendState()
			self:next()
		end
	elseif self.state == "startMissed" then
		if self.keyState then
			self.state = "startMissedPressed"
			self:sendState()
		elseif endTimeState == "late" then
			self.state = "endMissed"
			self:sendState()
			self:next()
		end
	end
end

LongLogicalNote.getFakeStartTime = function(self)
	if self.state == "startPassedPressed" and self.fakeStartTime then
		return self.engine.currentTime
	else
		return self.fakeStartTime
	end
end