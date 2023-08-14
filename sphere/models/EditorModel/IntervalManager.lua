local class = require("class")

local IntervalManager = class()

function IntervalManager:grab(intervalData)
	self.grabbedIntervalData = intervalData
end

function IntervalManager:drop()
	self.grabbedIntervalData = nil
end

function IntervalManager:isGrabbed()
	return self.grabbedIntervalData
end

function IntervalManager:moveGrabbed(time)
	self.editorModel.layerData:moveInterval(self.grabbedIntervalData, time)
end

function IntervalManager:split(timePoint)
	local ld = self.editorModel.layerData
	return ld:splitInterval(ld:getTimePoint(timePoint:getTime()))
end

function IntervalManager:merge(timePoint)
	self.editorModel.layerData:mergeInterval(timePoint)
end

function IntervalManager:update(intervalData, beats)
	self.editorModel.layerData:updateInterval(intervalData, beats)
end

return IntervalManager
