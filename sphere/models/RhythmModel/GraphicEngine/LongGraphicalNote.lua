local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")
local Point = require("ncdk2.tp.Point")
local VisualPoint = require("ncdk2.visual.VisualPoint")

---@class sphere.LongGraphicalNote: sphere.GraphicalNote
---@operator call: sphere.LongGraphicalNote
local LongGraphicalNote = GraphicalNote + {}

function LongGraphicalNote:checkFakeStartTimePoint()
	local visualPoint = self.startNote.visualPoint
	if self.baseStartTime == visualPoint.point.absoluteTime then
		return
	end
	self.baseStartTime = visualPoint.point.absoluteTime

	local fakeStartPoint = Point(visualPoint.point.absoluteTime)
	local fakeStartVisualPoint = VisualPoint(fakeStartPoint)
	self.fakeStartPoint = fakeStartPoint
	self.fakeStartTimePoint = fakeStartVisualPoint

	fakeStartVisualPoint.visualTime = visualPoint.visualTime
	fakeStartVisualPoint.velocity = visualPoint.velocity

	self.fakeIndex = 1
end

function LongGraphicalNote:update()
	self:checkFakeStartTimePoint()

	self.endNote = self.startNote.endNote

	local startVisualPoint = self.startNote.visualPoint
	local endVisualPoint = self.endNote.visualPoint
	local startPoint = startVisualPoint.point
	local endPoint = endVisualPoint.point

	local startVisualTime = self:getVisualTime(startVisualPoint)
	local endVisualTime = self:getVisualTime(endVisualPoint)

	self.startTimeState = self.startTimeState or {}
	local startTimeState = self.startTimeState

	local currentTime = self.graphicEngine:getCurrentTime()
	local visualOffset = self.graphicEngine:getVisualOffset()
	local visualTimeRate = self.graphicEngine:getVisualTimeRate()

	startTimeState.currentTime = currentTime

	startTimeState.absoluteTime = startPoint.absoluteTime
	startTimeState.currentVisualTime = startVisualTime
	startTimeState.absoluteDeltaTime = currentTime - startPoint.absoluteTime
	startTimeState.visualDeltaTime = currentTime - (startVisualTime + visualOffset)
	startTimeState.scaledAbsoluteDeltaTime = startTimeState.absoluteDeltaTime * visualTimeRate
	startTimeState.scaledVisualDeltaTime = startTimeState.visualDeltaTime * visualTimeRate

	startTimeState.fakeCurrentVisualTime = self:getFakeVisualStartTime()
	startTimeState.fakeVisualDeltaTime = currentTime - (startTimeState.fakeCurrentVisualTime + visualOffset)
	startTimeState.scaledFakeVisualDeltaTime = startTimeState.fakeVisualDeltaTime * visualTimeRate

	self.endTimeState = self.endTimeState or {}
	local endTimeState = self.endTimeState

	endTimeState.currentTime = currentTime

	endTimeState.absoluteTime = endPoint.absoluteTime
	endTimeState.currentVisualTime = endVisualTime
	endTimeState.absoluteDeltaTime = currentTime - endPoint.absoluteTime
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

---@param time number
function LongGraphicalNote:clampAbsoluteTime(time)
	time = math.max(time, self.startNote.visualPoint.point.absoluteTime)
	time = math.min(time, self.endNote.visualPoint.point.absoluteTime)
	return time
end

---@return number
function LongGraphicalNote:getFakeVisualStartTime()
	local currentVisualPoint = self.currentVisualPoint
	local fakeStartVisualPoint = self.fakeStartTimePoint
	local fakeStartPoint = self.fakeStartPoint

	local logicalState = self:getLogicalState()
	if logicalState == "endPassed" then
		return self:getVisualTime(self.endNote.visualPoint)
	end
	if logicalState ~= "startPassedPressed" then
		return self:getVisualTime(fakeStartVisualPoint)
	end

	local offsetSum = self.graphicEngine:getVisualOffset() - self.graphicEngine:getInputOffset()
	local globalSpeed = currentVisualPoint.globalSpeed

	local interpolator = self.layer.visual.interpolator
	local visualPoints = self.layer.visual.points

	if self.graphicEngine.constant then
		local fakeStartTime = currentVisualPoint.point.absoluteTime - offsetSum / globalSpeed
		fakeStartVisualPoint.point.absoluteTime = self:clampAbsoluteTime(fakeStartTime)
		return fakeStartVisualPoint.point.absoluteTime
	end

	fakeStartVisualPoint.visualTime = currentVisualPoint.visualTime - offsetSum / globalSpeed
	self.fakeIndex = interpolator:interpolate(visualPoints, self.fakeIndex, fakeStartVisualPoint, "visual")

	fakeStartPoint.absoluteTime = self:clampAbsoluteTime(fakeStartPoint.absoluteTime)
	self.fakeIndex = interpolator:interpolate(visualPoints, self.fakeIndex, fakeStartVisualPoint, "absolute")

	return fakeStartVisualPoint:getVisualTime(self.currentVisualPoint)
end

---@return number
function LongGraphicalNote:whereWillDraw()
	local wwdStart = self:where(self.startTimeState.scaledVisualDeltaTime)
	local wwdEnd = self:where(self.endTimeState.scaledVisualDeltaTime)

	if wwdStart == wwdEnd then
		return wwdStart
	end

	return 0
end

return LongGraphicalNote
