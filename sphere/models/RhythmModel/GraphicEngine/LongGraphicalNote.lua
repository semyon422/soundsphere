local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

local LongGraphicalNote = GraphicalNote:new()

LongGraphicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.endNoteData = self.noteData.endNoteData
	self.noteData = nil
end

LongGraphicalNote.update = function(self)
	self:computeVisualTime()
	self:computeTimeState()

	return self:tryNext()
end

LongGraphicalNote.computeVisualTime = function(self)
	self.startNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
	self.endNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
end

LongGraphicalNote.computeTimeState = function(self)
	self.startTimeState = self.startTimeState or {}
	local startTimeState = self.startTimeState

	local currentTime = self.graphicEngine.currentTime

	startTimeState.currentTime = currentTime

	startTimeState.absoluteTime = self.startNoteData.timePoint.absoluteTime
	startTimeState.currentVisualTime = self.startNoteData.timePoint.currentVisualTime
	startTimeState.absoluteDeltaTime = currentTime - self.startNoteData.timePoint.absoluteTime
	startTimeState.visualDeltaTime = currentTime - self.startNoteData.timePoint.currentVisualTime
	startTimeState.scaledVisualDeltaTime = startTimeState.visualDeltaTime * self.graphicEngine:getVisualTimeRate()

	startTimeState.fakeCurrentVisualTime = self:getFakeVisualStartTime() or self.startNoteData.timePoint.currentVisualTime
	startTimeState.fakeVisualDeltaTime = startTimeState.currentTime - startTimeState.fakeCurrentVisualTime
	startTimeState.scaledFakeVisualDeltaTime = startTimeState.fakeVisualDeltaTime * self.graphicEngine:getVisualTimeRate()

	self.endTimeState = self.endTimeState or {}
	local endTimeState = self.endTimeState

	endTimeState.currentTime = currentTime

	endTimeState.absoluteTime = self.endNoteData.timePoint.absoluteTime
	endTimeState.currentVisualTime = self.endNoteData.timePoint.currentVisualTime
	endTimeState.absoluteDeltaTime = currentTime - self.endNoteData.timePoint.absoluteTime
	endTimeState.visualDeltaTime = currentTime - self.endNoteData.timePoint.currentVisualTime
	endTimeState.scaledVisualDeltaTime = endTimeState.visualDeltaTime * self.graphicEngine:getVisualTimeRate()

	local longNoteShortening = self.graphicEngine.longNoteShortening
	endTimeState.fakeCurrentVisualTime = math.max(startTimeState.fakeCurrentVisualTime, self.endNoteData.timePoint.currentVisualTime + longNoteShortening)
	endTimeState.fakeVisualDeltaTime = endTimeState.currentTime - endTimeState.fakeCurrentVisualTime
	endTimeState.scaledFakeVisualDeltaTime = endTimeState.fakeVisualDeltaTime * self.graphicEngine:getVisualTimeRate()

	endTimeState.startTimeState = startTimeState
	startTimeState.endTimeState = endTimeState
end

LongGraphicalNote.updateFakeStartTime = function(self)
	local currentTime = self.graphicEngine.currentTime
	local startTime = self.startNoteData.timePoint.absoluteTime
	local endTime = self.endNoteData.timePoint.absoluteTime
	self.fakeStartTime = currentTime > startTime and currentTime or startTime
	self.fakeStartTime = math.min(self.fakeStartTime, endTime)
end

LongGraphicalNote.getFakeStartTime = function(self)
	if self.logicalNote.state == "startPassedPressed" then
		self:updateFakeStartTime()
		return self.fakeStartTime
	else
		return self.fakeStartTime or self.startNoteData.timePoint.absoluteTime
	end
end

LongGraphicalNote.getFakeVelocityData = function(self)
	if self.logicalNote.state == "startPassedPressed" and self.fakeStartTime then
		return "current"
	else
		return self.fakeVelocityData or self.startNoteData.timePoint.velocityData
	end
end

LongGraphicalNote.getFakeVisualStartTime = function(self)
	local fakeStartTime = self:getFakeStartTime()
	local fakeVelocityData = self:getFakeVelocityData()
	if fakeVelocityData == "current" then
		fakeVelocityData = self.noteDrawer.currentVelocityData
		self.fakeVelocityData = fakeVelocityData
	end

	local fakeVisualClearStartTime
		= (fakeStartTime - fakeVelocityData.timePoint.absoluteTime)
		* fakeVelocityData.currentSpeed
		+ fakeVelocityData.timePoint.zeroClearVisualTime

	local fakeVisualStartTime
		= (fakeVisualClearStartTime - self.noteDrawer.currentTimePoint.zeroClearVisualTime)
		* self.noteDrawer.globalSpeed
		+ self.noteDrawer.currentTimePoint.absoluteTime

	return fakeVisualStartTime
end

LongGraphicalNote.whereWillDraw = function(self)
	local wwdStart = self:where(self.startTimeState.scaledVisualDeltaTime)
	local wwdEnd = self:where(self.endTimeState.scaledVisualDeltaTime)

	if wwdStart == wwdEnd then
		return wwdStart
	end

	return 0
end

return LongGraphicalNote
