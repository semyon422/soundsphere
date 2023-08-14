local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")
local TimePoint = require("ncdk.TimePoint")

local LongGraphicalNote = GraphicalNote + {}

function LongGraphicalNote:checkFakeStartTimePoint()
	local timePoint = self.startNoteData.timePoint
	if self.baseStartTime == timePoint.absoluteTime then
		return
	end
	self.baseStartTime = timePoint.absoluteTime

	self.fakeStartTimePoint = self.fakeStartTimePoint or TimePoint()

	local fakeTimePoint = self.fakeStartTimePoint
	fakeTimePoint.absoluteTime = timePoint.absoluteTime
	fakeTimePoint.visualTime = timePoint.visualTime
	fakeTimePoint.velocityData = timePoint.velocityData
	fakeTimePoint.tempoData = timePoint.tempoData
	fakeTimePoint.index = timePoint.index
end

function LongGraphicalNote:update()
	self:checkFakeStartTimePoint()

	self.endNoteData = self.startNoteData.endNoteData

	local startTimePoint = self.startNoteData.timePoint
	local endTimePoint = self.endNoteData.timePoint
	local startVisualTime = startTimePoint:getVisualTime(self.currentTimePoint)
	local endVisualTime = endTimePoint:getVisualTime(self.currentTimePoint)

	self.startTimeState = self.startTimeState or {}
	local startTimeState = self.startTimeState

	local currentTime = self.graphicEngine:getCurrentTime()
	local visualOffset = self.graphicEngine:getVisualOffset()
	local visualTimeRate = self.graphicEngine:getVisualTimeRate()

	startTimeState.currentTime = currentTime

	startTimeState.absoluteTime = startTimePoint.absoluteTime
	startTimeState.currentVisualTime = startVisualTime
	startTimeState.absoluteDeltaTime = currentTime - startTimePoint.absoluteTime
	startTimeState.visualDeltaTime = currentTime - (startVisualTime + visualOffset)
	startTimeState.scaledAbsoluteDeltaTime = startTimeState.absoluteDeltaTime * visualTimeRate
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
	endTimeState.scaledAbsoluteDeltaTime = endTimeState.absoluteDeltaTime * visualTimeRate
	endTimeState.scaledVisualDeltaTime = endTimeState.visualDeltaTime * visualTimeRate

	local longNoteShortening = self.graphicEngine.longNoteShortening
	endTimeState.fakeCurrentVisualTime = math.max(startTimeState.fakeCurrentVisualTime, endVisualTime + longNoteShortening)
	endTimeState.fakeVisualDeltaTime = currentTime - (endTimeState.fakeCurrentVisualTime + visualOffset)
	endTimeState.scaledFakeVisualDeltaTime = endTimeState.fakeVisualDeltaTime * visualTimeRate

	endTimeState.startTimeState = startTimeState
	startTimeState.endTimeState = endTimeState
end

function LongGraphicalNote:getFakeVisualStartTime()
	local currentTimePoint = self.currentTimePoint
	local fakeTimePoint = self.fakeStartTimePoint

	local logicalState = self:getLogicalState()
	if logicalState == "endPassed" then
		return self.endNoteData.timePoint:getVisualTime(currentTimePoint)
	end
	if logicalState ~= "startPassedPressed" then
		return fakeTimePoint:getVisualTime(currentTimePoint)
	end

	local offsetSum = self.graphicEngine:getVisualOffset() - self.graphicEngine:getInputOffset()

	local globalSpeed = currentTimePoint.velocityData and currentTimePoint.velocityData.globalSpeed or 1
	fakeTimePoint.visualTime = currentTimePoint.visualTime - offsetSum / globalSpeed
	fakeTimePoint.index = self.layerData:interpolateTimePointVisual(fakeTimePoint.index, fakeTimePoint)

	local fakeStartTime = fakeTimePoint.absoluteTime
	fakeStartTime = math.max(fakeStartTime, self.startNoteData.timePoint.absoluteTime)
	fakeStartTime = math.min(fakeStartTime, self.endNoteData.timePoint.absoluteTime)
	fakeTimePoint.absoluteTime = fakeStartTime
	fakeTimePoint.index = self.layerData:interpolateTimePointAbsolute(fakeTimePoint.index, fakeTimePoint)

	return fakeTimePoint:getVisualTime(self.currentTimePoint)
end

function LongGraphicalNote:whereWillDraw()
	local wwdStart = self:where(self.startTimeState.scaledVisualDeltaTime)
	local wwdEnd = self:where(self.endTimeState.scaledVisualDeltaTime)

	if wwdStart == wwdEnd then
		return wwdStart
	end

	return 0
end

return LongGraphicalNote
