local Class = require("Class")

local IntervalManager = Class:new()

IntervalManager.grab = function(self, intervalData)
	self.grabbedIntervalData = intervalData
end

IntervalManager.drop = function(self)
	self.grabbedIntervalData = nil
end

IntervalManager.isGrabbed = function(self)
	return self.grabbedIntervalData
end

IntervalManager.moveGrabbed = function(self, time)
	self.layerData:moveInterval(self.grabbedIntervalData, time)
end

IntervalManager.split = function(self, timePoint)
	local ld = self.layerData
	return ld:splitInterval(ld:getTimePoint(timePoint:getTime()))
end

IntervalManager.merge = function(self, timePoint)
	self.layerData:mergeInterval(timePoint)
end

IntervalManager.update = function(self, intervalData, beats)
	self.layerData:updateInterval(intervalData, beats)
end

return IntervalManager