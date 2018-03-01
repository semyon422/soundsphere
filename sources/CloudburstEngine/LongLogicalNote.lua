CloudburstEngine.LongLogicalNote = createClass(CloudburstEngine.LogicalNote)
local LongLogicalNote = CloudburstEngine.LongLogicalNote


LongLogicalNote.update = function(self)
	if self.state == "endPassed" or self.state == "endMissed" or self.state == "endMissedPassed" then
		return
	end
	
	local deltaStartTime = self.noteData.startTimePoint:getAbsoluteTime() - self.engine.currentTime
	local deltaEndTime = self.noteData.endTimePoint:getAbsoluteTime() - self.engine.currentTime
	
	local startTimeState = self.engine:getTimeState(deltaStartTime)
	local endTimeState = self.engine:getTimeState(deltaEndTime)
	
	if self.keyState and timeState == "none" then
		self.keyState = false
	elseif self.state == "clear" then
		if startTimeState == "late" then
			self.state = "startMissed"
		elseif self.keyState then
			if startTimeState == "early" then
				self.state = "startMissedPressed"
			elseif startTimeState == "exactly" then
				self.state = "startPassedPressed"
			end
		end
	elseif self.state == "startPassedPressed" then
		self.fakeStartTime = self.engine.currentTime
		if not self.keyState then
			if endTimeState == "none" then
				self.state = "startMissed"
			elseif endTimeState == "exactly" then
				self.state = "endPassed"
				self:next()
			end
		elseif endTimeState == "late" then
			self.state = "endMissed"
			self:next()
		end
	elseif self.state == "startMissedPressed" then
		if not self.keyState then
			if endTimeState == "exactly" then
				self.state = "endMissedPassed"
				self:next()
			else
				self.state = "startMissed"
			end
		elseif endTimeState == "late" then
			self.state = "endMissed"
			self:next()
		end
	elseif self.state == "startMissed" then
		if self.keyState then
			self.state = "startMissedPressed"
		elseif endTimeState == "late" then
			self.state = "endMissed"
			self:next()
		end
	end
end