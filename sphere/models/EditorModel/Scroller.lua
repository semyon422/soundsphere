local class = require("class")
local Fraction = require("ncdk.Fraction")

---@class sphere.Scroller
---@operator call: sphere.Scroller
local Scroller = class()

function Scroller:updateRange()
	local editor = self.editorModel:getSettings()
	local absoluteTime = self.editorModel.timePoint.absoluteTime

	local ld = self.editorModel.layerData
	local delta = 1 / editor.speed
	if ld.startTime ~= absoluteTime - delta then
		-- ld:setRange(absoluteTime - delta, absoluteTime + delta)
	end
end

---@param timePoint ncdk.IntervalTimePoint
function Scroller:_scrollTimePoint(timePoint)
	if not timePoint then
		return
	end

	timePoint:clone(self.editorModel.timePoint)

	self:updateRange()
end

---@param timePoint ncdk.IntervalTimePoint
function Scroller:scrollTimePoint(timePoint)
	if not timePoint then
		return
	end

	self:_scrollTimePoint(timePoint)

	local editorModel = self.editorModel
	editorModel:setTime(timePoint.absoluteTime)
end

---@param absoluteTime number
function Scroller:scrollSeconds(absoluteTime)
	local timePoint = self.editorModel:getDtpAbsolute(absoluteTime)
	self:scrollTimePoint(timePoint)
end

---@param delta number
function Scroller:scrollSecondsDelta(delta)
	self:scrollSeconds(self.editorModel.timePoint.absoluteTime + delta)
end

---@param delta number
function Scroller:scrollSnaps(delta)
	if self.editorModel.intervalManager:isGrabbed() then
		return
	end
	local ld = self.editorModel.layerData
	self:scrollTimePoint(ld.points:interpolateFraction(self:getNextSnapIntervalTime(self.editorModel.timePoint, delta)))
end

---@param point chartedit.Point
---@param delta number
---@return chartedit.Interval
---@return ncdk.Fraction
function Scroller:getNextSnapIntervalTime(point, delta)
	local editor = self.editorModel:getSettings()

	local snap = editor.snap
	local snapTime = point.time * snap

	local targetSnapTime
	if delta == -1 then
		targetSnapTime = snapTime:ceil() - 1
	else
		targetSnapTime = snapTime:floor() + 1
	end

	local interval = point.interval
	-- if intervalData.next and targetSnapTime >= snap * intervalData:_end() then
	-- 	intervalData = intervalData.next
	-- 	targetSnapTime = intervalData:start() * snap
	-- elseif intervalData.prev and dtp.time > intervalData:start() and targetSnapTime < snap * intervalData:start() then
	-- 	targetSnapTime = intervalData:start() * snap
	-- elseif intervalData.prev and dtp.time == intervalData:start() and targetSnapTime < snap * intervalData:start() then
	-- 	intervalData = intervalData.prev
	-- 	targetSnapTime = (intervalData:_end() * snap):ceil() - 1
	-- end

	if interval.next and targetSnapTime == snap * interval:_end() then
		interval = interval.next
		targetSnapTime = interval:start() * snap
	elseif interval.next and targetSnapTime > snap * interval:_end() then
		interval = interval.next
		targetSnapTime = (interval:start() * snap):floor() + 1
	elseif interval.prev and targetSnapTime < snap * interval:start() then
		interval = interval.prev
		targetSnapTime = (interval:_end() * snap):ceil() - 1
	end

	return interval, Fraction(targetSnapTime, snap)
end

return Scroller
