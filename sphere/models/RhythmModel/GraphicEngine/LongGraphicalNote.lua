local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")
local TimePoint = require("ncdk.TimePoint")

local LongGraphicalNote = GraphicalNote:new()

LongGraphicalNote.construct = function(self)
	self.endNoteData = self.startNoteData.endNoteData
	self.fakeStartTimePoint = TimePoint:new()
end

LongGraphicalNote.update = function(self)
	local startTimePoint = self.startNoteData.timePoint
	local endTimePoint = self.endNoteData.timePoint
	local startVisualTime = startTimePoint:getVisualTime(self.currentTimePoint)
	local endVisualTime = endTimePoint:getVisualTime(self.currentTimePoint)

	self.startTimeState = self.startTimeState or {}
	local startTimeState = self.startTimeState

	local currentTime = self.timeEngine.currentVisualTime
	local visualOffset = self.timeEngine.visualOffset
	local visualTimeRate = self.graphicEngine:getVisualTimeRate()

	startTimeState.currentTime = currentTime

	startTimeState.absoluteTime = startTimePoint.absoluteTime
	startTimeState.currentVisualTime = startVisualTime
	startTimeState.absoluteDeltaTime = currentTime - startTimePoint.absoluteTime
	startTimeState.visualDeltaTime = currentTime - (startVisualTime + visualOffset)
	startTimeState.scaledVisualDeltaTime = startTimeState.visualDeltaTime * visualTimeRate

	startTimeState.fakeCurrentVisualTime = self:getFakeVisualStartTime()
	startTimeState.fakeVisualDeltaTime = currentTime - (startTimeState.fakeCurrentVisualTime + visualOffset)
	startTimeState.scaledFakeVisualDeltaTime = startTimeState.fakeVisualDeltaTime * visualTimeRate

	self.endTimeState = self.endTimeState or {}
	local endTimeState = self.endTimeState

	endTimeState.currentTime = currentTime

	endTimeState.absoluteTime = endTimePoint.absoluteTime
	endTimeState.currentVisualTime = endVisualTime
	endTimeState.absoluteDeltaTime = currentTime - endTimePoint.absoluteTime
	endTimeState.visualDeltaTime = currentTime - (endVisualTime + visualOffset)
	endTimeState.scaledVisualDeltaTime = endTimeState.visualDeltaTime * visualTimeRate

	local longNoteShortening = self.graphicEngine.longNoteShortening
	endTimeState.fakeCurrentVisualTime = math.max(startTimeState.fakeCurrentVisualTime, endVisualTime + visualOffset + longNoteShortening)
	endTimeState.fakeVisualDeltaTime = currentTime - endTimeState.fakeCurrentVisualTime
	endTimeState.scaledFakeVisualDeltaTime = endTimeState.fakeVisualDeltaTime * visualTimeRate

	endTimeState.startTimeState = startTimeState
	startTimeState.endTimeState = endTimeState
end

LongGraphicalNote.getFakeStartTime = function(self)
	local startTime = self.startNoteData.timePoint.absoluteTime
	local logicalNote = self.logicalNote
	if not logicalNote or logicalNote.state ~= "startPassedPressed" then
		return self.fakeStartTime or startTime
	end

	local timePoint = self.currentTimePoint
	local offsetSum = self.timeEngine.visualOffset - self.timeEngine.inputOffset
	local velocityData = self.startNoteData.timePoint.velocityData

	local deltaZeroClearVisualStartTime
		= timePoint.visualTime
		- velocityData.timePoint.visualTime
		- offsetSum / timePoint.velocityData.globalSpeed

	local deltaZeroClearVisualEndTime
		= self.endNoteData.timePoint.visualTime
		- velocityData.timePoint.visualTime

	--[[
		fakeVisualStartTimeLimit is derived
		from (fakeVisualStartTime == currentTime == currentVisualTime)
		as fakeStartTime
	]]
	local startTimeLimit = deltaZeroClearVisualStartTime
	local endTimeLimit = deltaZeroClearVisualEndTime
	startTime = (startTime - velocityData.timePoint.absoluteTime) * velocityData.currentSpeed

	self.fakeStartTime = math.min(startTimeLimit > startTime and startTimeLimit or startTime, endTimeLimit)
	self.fakeStartTime = self.fakeStartTime / velocityData.currentSpeed + velocityData.timePoint.absoluteTime
	return self.fakeStartTime
end

LongGraphicalNote.getFakeVisualStartTime = function(self)
	local timePoint = self.fakeStartTimePoint

	timePoint.velocityData = self.startNoteData.timePoint.velocityData
	timePoint.absoluteTime = self:getFakeStartTime()
	timePoint:computeVisualTime()

	return timePoint:getVisualTime(self.currentTimePoint)
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
