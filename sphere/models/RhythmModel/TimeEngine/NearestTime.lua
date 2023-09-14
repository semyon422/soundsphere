local class = require("class")

---@class sphere.NearestTime
---@operator call: sphere.NearestTime
local NearestTime = class()

function NearestTime:new(window)
	self.window = window
	self.absoluteTimeList = {}
	self.nextTimeIndex = 1
end

function NearestTime:loadTimePoints(noteChart)
	local absoluteTimes = {}

	for _, layerData in noteChart:getLayerDataIterator() do
		local timePointList = layerData.timePointList
		for timePointIndex = 1, #timePointList do
			local t = timePointList[timePointIndex].absoluteTime
			if t == t then
				absoluteTimes[t] = true
			end
		end
	end

	local absoluteTimeList = {}
	for time in pairs(absoluteTimes) do
		absoluteTimeList[#absoluteTimeList + 1] = time
	end
	table.sort(absoluteTimeList)

	self.absoluteTimeList = absoluteTimeList
	self.nextTimeIndex = 1
end

---@return number
function NearestTime:getTime(currentTime)
	local timeList = self.absoluteTimeList
	while timeList[self.nextTimeIndex + 1] and currentTime >= timeList[self.nextTimeIndex] do
		self.nextTimeIndex = self.nextTimeIndex + 1
	end

	local prevTime = timeList[self.nextTimeIndex - 1]
	local nextTime = timeList[self.nextTimeIndex]

	if not prevTime then
		return nextTime
	end

	local currentTime = currentTime
	local prevDelta = math.abs(currentTime - prevTime)
	local nextDelta = math.abs(currentTime - nextTime)

	return prevDelta < nextDelta and prevTime or nextTime
end

---@return number
function NearestTime:getVisualTime(current)
	local nearest = self:getTime(current)
	if nearest and math.abs(current - nearest) <= self.window then
		return nearest
	end
	return current
end

return NearestTime
