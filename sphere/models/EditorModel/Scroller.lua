local Class = require("Class")
local Fraction = require("ncdk.Fraction")

local Scroller = Class:new()

Scroller.updateRange = function(self)
	local editor = self.editorModel:getSettings()
	local absoluteTime = self.editorModel.timePoint.absoluteTime

	local ld = self.editorModel.layerData
	local delta = 1 / editor.speed
	if ld.startTime ~= absoluteTime - delta then
		ld:setRange(absoluteTime - delta, absoluteTime + delta)
	end
end

Scroller._scrollTimePoint = function(self, timePoint)
	if not timePoint then
		return
	end

	timePoint:clone(self.editorModel.timePoint)

	self:updateRange()
end

Scroller.scrollTimePoint = function(self, timePoint)
	if not timePoint then
		return
	end

	self:_scrollTimePoint(timePoint)

	local timer = self.editorModel.timer
	timer:setTime(timePoint.absoluteTime)

	local audioManager = self.editorModel.audioManager
	audioManager:update(true)
end

Scroller.scrollSeconds = function(self, absoluteTime)
	local timePoint = self.editorModel:getDtpAbsolute(absoluteTime)
	self:scrollTimePoint(timePoint)
end

Scroller.scrollSecondsDelta = function(self, delta)
	self:scrollSeconds(self.editorModel.timePoint.absoluteTime + delta)
end

Scroller.scrollSnaps = function(self, delta)
	if self.editorModel.intervalManager:isGrabbed() then
		return
	end
	local ld = self.editorModel.layerData
	self:scrollTimePoint(ld:getDynamicTimePoint(self:getNextSnapIntervalTime(self.editorModel.timePoint, delta)))
end

Scroller.getNextSnapIntervalTime = function(self, timePoint, delta)
	local editor = self.editorModel:getSettings()

	local snap = editor.snap
	local snapTime = timePoint.time * snap

	local targetSnapTime
	if delta == -1 then
		targetSnapTime = snapTime:ceil() - 1
	else
		targetSnapTime = snapTime:floor() + 1
	end

	local intervalData = timePoint.intervalData
	-- if intervalData.next and targetSnapTime >= snap * intervalData:_end() then
	-- 	intervalData = intervalData.next
	-- 	targetSnapTime = intervalData:start() * snap
	-- elseif intervalData.prev and dtp.time > intervalData:start() and targetSnapTime < snap * intervalData:start() then
	-- 	targetSnapTime = intervalData:start() * snap
	-- elseif intervalData.prev and dtp.time == intervalData:start() and targetSnapTime < snap * intervalData:start() then
	-- 	intervalData = intervalData.prev
	-- 	targetSnapTime = (intervalData:_end() * snap):ceil() - 1
	-- end

	if intervalData.next and targetSnapTime == snap * intervalData:_end() then
		intervalData = intervalData.next
		targetSnapTime = intervalData:start() * snap
	elseif intervalData.next and targetSnapTime > snap * intervalData:_end() then
		intervalData = intervalData.next
		targetSnapTime = (intervalData:start() * snap):floor() + 1
	elseif intervalData.prev and targetSnapTime < snap * intervalData:start() then
		intervalData = intervalData.prev
		targetSnapTime = (intervalData:_end() * snap):ceil() - 1
	end

	return intervalData, Fraction(targetSnapTime, snap)
end

return Scroller
