local class = require("class")

---@class sphere.IntervalManager
---@operator call: sphere.IntervalManager
local IntervalManager = class()

---@param intervalData ncdk.IntervalData
function IntervalManager:grab(intervalData)
	self.grabbedIntervalData = intervalData
end

function IntervalManager:drop()
	self.grabbedIntervalData = nil
end

---@return boolean
function IntervalManager:isGrabbed()
	return self.grabbedIntervalData ~= nil
end

---@param time number
function IntervalManager:moveGrabbed(time)
	self.editorModel.layerData:moveInterval(self.grabbedIntervalData, time)
end

---@param timePoint ncdk.IntervalTimePoint
---@return ncdk.IntervalData
function IntervalManager:split(timePoint)
	local ld = self.editorModel.layerData
	return ld:splitInterval(ld:getTimePoint(timePoint:getTime()))
end

---@param timePoint ncdk.IntervalTimePoint
function IntervalManager:merge(timePoint)
	self.editorModel.layerData:mergeInterval(timePoint)
end

---@param intervalData ncdk.IntervalData
---@param beats number
function IntervalManager:update(intervalData, beats)
	self.editorModel.layerData:updateInterval(intervalData, beats)
end

return IntervalManager
