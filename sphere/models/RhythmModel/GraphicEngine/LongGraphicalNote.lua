local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

local LongGraphicalNote = GraphicalNote:new()

LongGraphicalNote.construct = function(self)
	self.startNoteData = self.noteData
	self.endNoteData = self.noteData.endNoteData
	self.noteData = nil
end

LongGraphicalNote.computeVisualTime = function(self)
	self.startNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
	self.endNoteData.timePoint:computeVisualTime(self.noteDrawer.currentTimePoint)
end

LongGraphicalNote.computeTimeState = function(self)
	self.startTimeState = self.startTimeState or {}
	local startTimeState = self.startTimeState

	local currentTime = self.timeEngine.currentVisualTime
	local visualOffset = self.timeEngine.visualOffset
	local visualTimeRate = self.graphicEngine:getVisualTimeRate()

	startTimeState.currentTime = currentTime

	startTimeState.absoluteTime = self.startNoteData.timePoint.absoluteTime
	startTimeState.currentVisualTime = self.startNoteData.timePoint.currentVisualTime
	startTimeState.absoluteDeltaTime = currentTime - self.startNoteData.timePoint.absoluteTime
	startTimeState.visualDeltaTime = currentTime - (self.startNoteData.timePoint.currentVisualTime + visualOffset)
	startTimeState.scaledVisualDeltaTime = startTimeState.visualDeltaTime * visualTimeRate

	startTimeState.fakeCurrentVisualTime = self:getFakeVisualStartTime()
	startTimeState.fakeVisualDeltaTime = currentTime - (startTimeState.fakeCurrentVisualTime + visualOffset)
	startTimeState.scaledFakeVisualDeltaTime = startTimeState.fakeVisualDeltaTime * visualTimeRate

	self.endTimeState = self.endTimeState or {}
	local endTimeState = self.endTimeState

	endTimeState.currentTime = currentTime

	endTimeState.absoluteTime = self.endNoteData.timePoint.absoluteTime
	endTimeState.currentVisualTime = self.endNoteData.timePoint.currentVisualTime
	endTimeState.absoluteDeltaTime = currentTime - self.endNoteData.timePoint.absoluteTime
	endTimeState.visualDeltaTime = currentTime - (self.endNoteData.timePoint.currentVisualTime + visualOffset)
	endTimeState.scaledVisualDeltaTime = endTimeState.visualDeltaTime * visualTimeRate

	local longNoteShortening = self.graphicEngine.longNoteShortening
	endTimeState.fakeCurrentVisualTime = math.max(startTimeState.fakeCurrentVisualTime, self.endNoteData.timePoint.currentVisualTime + visualOffset + longNoteShortening)
	endTimeState.fakeVisualDeltaTime = currentTime - endTimeState.fakeCurrentVisualTime
	endTimeState.scaledFakeVisualDeltaTime = endTimeState.fakeVisualDeltaTime * visualTimeRate

	endTimeState.startTimeState = startTimeState
	startTimeState.endTimeState = endTimeState
end

LongGraphicalNote.getFakeStartTime = function(self)
	local startTime = self.startNoteData.timePoint.absoluteTime
	if self.logicalNote.state == "startPassedPressed" then
		local timePoint = self.noteDrawer.currentTimePoint
		local offsetSum = self.timeEngine.visualOffset - self.timeEngine.inputOffset
		local velocityData = self.startNoteData.timePoint.velocityData

		local deltaZeroClearVisualStartTime
			= timePoint.zeroClearVisualTime
			- velocityData.timePoint.zeroClearVisualTime
			- offsetSum / self.noteDrawer.globalSpeed

		local deltaZeroClearVisualEndTime
			= self.endNoteData.timePoint.zeroClearVisualTime
			- velocityData.timePoint.zeroClearVisualTime

		--[[
			fakeVisualStartTimeLimit is derived
			from (fakeVisualStartTime == currentTime == currentVisualTime)
			as fakeStartTime
		]]
		local startTimeLimit = deltaZeroClearVisualStartTime / velocityData.currentSpeed + velocityData.timePoint.absoluteTime
		local endTimeLimit = deltaZeroClearVisualEndTime / velocityData.currentSpeed + velocityData.timePoint.absoluteTime

		self.fakeStartTime = math.min(startTimeLimit > startTime and startTimeLimit or startTime, endTimeLimit)
	end
	return self.fakeStartTime or startTime
end

LongGraphicalNote.getFakeVisualStartTime = function(self)
	local timePoint = self.noteDrawer.currentTimePoint

	local velocityData = self.startNoteData.timePoint.velocityData
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
