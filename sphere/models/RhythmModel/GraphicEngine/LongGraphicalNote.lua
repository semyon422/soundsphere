local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")
local TimePoint = require("ncdk.TimePoint")

local LongGraphicalNote = GraphicalNote:new()

LongGraphicalNote.construct = function(self)
	self.endNoteData = self.startNoteData.endNoteData

	local timePoint = self.startNoteData.timePoint
	local fakeTimePoint = TimePoint:new()
	fakeTimePoint.absoluteTime = timePoint.absoluteTime
	fakeTimePoint.visualTime = timePoint.visualTime
	fakeTimePoint.velocityData = timePoint.velocityData
	fakeTimePoint.tempoData = timePoint.tempoData
	fakeTimePoint.index = timePoint.index
	self.fakeStartTimePoint = fakeTimePoint
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
	endTimeState.fakeCurrentVisualTime = math.max(startTimeState.fakeCurrentVisualTime, endVisualTime + longNoteShortening)
	endTimeState.fakeVisualDeltaTime = currentTime - (endTimeState.fakeCurrentVisualTime + visualOffset)
	endTimeState.scaledFakeVisualDeltaTime = endTimeState.fakeVisualDeltaTime * visualTimeRate

	endTimeState.startTimeState = startTimeState
	startTimeState.endTimeState = endTimeState
end

LongGraphicalNote.getFakeVisualStartTime = function(self)
	local logicalNote = self.logicalNote
	local currentTimePoint = self.currentTimePoint
	local fakeTimePoint = self.fakeStartTimePoint
	if not logicalNote or logicalNote.state ~= "startPassedPressed" then
		return fakeTimePoint:getVisualTime(currentTimePoint)
	end

	local offsetSum = self.timeEngine.visualOffset - self.timeEngine.inputOffset

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

LongGraphicalNote.whereWillDraw = function(self)
	local wwdStart = self:where(self.startTimeState.scaledVisualDeltaTime)
	local wwdEnd = self:where(self.endTimeState.scaledVisualDeltaTime)

	if wwdStart == wwdEnd then
		return wwdStart
	end

	return 0
end

return LongGraphicalNote
