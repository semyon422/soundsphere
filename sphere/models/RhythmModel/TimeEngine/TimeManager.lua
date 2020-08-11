local Timer = require("aqua.util.Timer")

local TimeManager = Timer:new()

TimeManager.currentTime = -1

TimeManager.getAbsoluteTime = function(self)
	return self.eventTime or Timer.getAbsoluteTime(self)
end

TimeManager.getAbsoluteDelta = function(self)
	return self.eventDelta or Timer.getAbsoluteDelta(self)
end

TimeManager.load = function(self)
	self.rate = Timer.rate
	self.offset = Timer.offset
	self.pauseTime = Timer.pauseTime
	self.adjustDelta = Timer.adjustDelta
	self.rateDelta = Timer.rateDelta
	self.positionDelta = Timer.positionDelta
	self.state = Timer.state

	self.currentTime = TimeManager.currentTime

	self:loadTimePoints()
end

TimeManager.getAdjustTime = function(self)
	return self.timeEngine.audioEngine:getPosition()
end

TimeManager.loadTimePoints = function(self)
	local absoluteTimes = {}

	local noteChart = self.timeEngine.noteChart
	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local timePointList = noteChart:requireLayerData(layerIndex).timeData.timePointList
		for timePointIndex = 1, #timePointList do
			local timePoint = timePointList[timePointIndex]
			absoluteTimes[timePoint.absoluteTime] = true
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

TimeManager.updateNextTimeIndex = function(self)
	local timeList = self.absoluteTimeList
	while true do
		if
			timeList[self.nextTimeIndex + 1] and
			self.currentTime >= timeList[self.nextTimeIndex]
		then
			self.nextTimeIndex = self.nextTimeIndex + 1
		else
			break
		end
	end
end

TimeManager.getNearestTime = function(self)
	local timeList = self.absoluteTimeList
	local prevTime = timeList[self.nextTimeIndex - 1]
	local nextTime = timeList[self.nextTimeIndex]

	if not prevTime then
		return nextTime
	end

	local prevDelta = math.abs(self.currentTime - prevTime)
	local nextDelta = math.abs(self.currentTime - nextTime)

	if prevDelta < nextDelta then
		return prevTime
	else
		return nextTime
	end
end

TimeManager.update = function(self)
	Timer.update(self)

	self:updateNextTimeIndex()
end

TimeManager.unload = function(self)

end

TimeManager.getTime = function(self)
	local nearestTime = self:getNearestTime()
	if math.abs(self.currentTime - nearestTime) < 0.001 then
		return nearestTime
	else
		return self.currentTime
	end
end

TimeManager.getExactTime = function(self)
	return self.currentTime
end

return TimeManager
