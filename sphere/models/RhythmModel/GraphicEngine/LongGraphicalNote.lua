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
	local visualOffset = self.timeEngine.visualOffset

	startTimeState.currentTime = currentTime

	startTimeState.absoluteTime = self.startNoteData.timePoint.absoluteTime
	startTimeState.currentVisualTime = self.startNoteData.timePoint.currentVisualTime
	startTimeState.absoluteDeltaTime = currentTime - self.startNoteData.timePoint.absoluteTime
	startTimeState.visualDeltaTime = currentTime - (self.startNoteData.timePoint.currentVisualTime + visualOffset)
	startTimeState.scaledVisualDeltaTime = startTimeState.visualDeltaTime * self.graphicEngine:getVisualTimeRate()

	startTimeState.fakeCurrentVisualTime = self:getFakeVisualStartTime()
	startTimeState.fakeVisualDeltaTime = currentTime - (startTimeState.fakeCurrentVisualTime + visualOffset)
	startTimeState.scaledFakeVisualDeltaTime = startTimeState.fakeVisualDeltaTime * self.graphicEngine:getVisualTimeRate()

	self.endTimeState = self.endTimeState or {}
	local endTimeState = self.endTimeState

	endTimeState.currentTime = currentTime

	endTimeState.absoluteTime = self.endNoteData.timePoint.absoluteTime
	endTimeState.currentVisualTime = self.endNoteData.timePoint.currentVisualTime
	endTimeState.absoluteDeltaTime = currentTime - self.endNoteData.timePoint.absoluteTime
	endTimeState.visualDeltaTime = currentTime - (self.endNoteData.timePoint.currentVisualTime + visualOffset)
	endTimeState.scaledVisualDeltaTime = endTimeState.visualDeltaTime * self.graphicEngine:getVisualTimeRate()

	local longNoteShortening = self.graphicEngine.longNoteShortening
	endTimeState.fakeCurrentVisualTime = math.max(startTimeState.fakeCurrentVisualTime, self.endNoteData.timePoint.currentVisualTime + visualOffset + longNoteShortening)
	endTimeState.fakeVisualDeltaTime = currentTime - endTimeState.fakeCurrentVisualTime
	endTimeState.scaledFakeVisualDeltaTime = endTimeState.fakeVisualDeltaTime * self.graphicEngine:getVisualTimeRate()

	endTimeState.startTimeState = startTimeState
	startTimeState.endTimeState = endTimeState
end

LongGraphicalNote.getFakeStartTime = function(self)
	local currentTime = self.fakeVisualStartTimeLimit
	local startTime = self.startNoteData.timePoint.absoluteTime
	local endTime = self.endNoteData.timePoint.absoluteTime
	if self.logicalNote.state == "startPassedPressed" then
		self.fakeStartTime = math.min(currentTime > startTime and currentTime or startTime, endTime)
	end
	return self.fakeStartTime or startTime
end

LongGraphicalNote.getFakeVisualStartTime = function(self)
	local timePoint = self.noteDrawer.currentTimePoint
	local offset = self.timeEngine.visualOffset

	local velocityData = self.startNoteData.timePoint.velocityData
	local offsetSum = self.timeEngine.visualOffset - self.timeEngine.inputOffset

	local deltaZeroClearVisualTime
		= timePoint.zeroClearVisualTime
		- velocityData.timePoint.zeroClearVisualTime
		- offsetSum / self.noteDrawer.globalSpeed

	--[[
		fakeVisualStartTimeLimit is derived
		from (fakeVisualStartTime == currentTime == currentVisualTime)
		as fakeStartTime
	]]
	self.fakeVisualStartTimeLimit = deltaZeroClearVisualTime / velocityData.currentSpeed + velocityData.timePoint.absoluteTime

	local fakeStartTime = self:getFakeStartTime()

	local fakeVisualClearStartTime
		= (fakeStartTime - velocityData.timePoint.absoluteTime)
		* velocityData.currentSpeed
		+ velocityData.timePoint.zeroClearVisualTime

	local fakeVisualStartTime
		= (fakeVisualClearStartTime - timePoint.zeroClearVisualTime)
		* self.noteDrawer.globalSpeed
		+ timePoint.absoluteTime

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
