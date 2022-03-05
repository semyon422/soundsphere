local Timer = require("aqua.util.Timer")

local TimeManager = Timer:new()

TimeManager.getAbsoluteTime = function(self)
	return self.eventTime
end

TimeManager.getAbsoluteDelta = function(self)
	return self.eventDelta
end

TimeManager.load = function(self)
	self:loadTimePoints()
	self:reset()
	self.eventTime = love.timer.getTime()
	self.eventDelta = 0
end

TimeManager.getAdjustTime = function(self)
	return self.timeEngine.rhythmModel.audioEngine:getPosition()
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

	return prevDelta < nextDelta and prevTime or nextTime
end

TimeManager.update = function(self)
	Timer.update(self)
	self:updateNextTimeIndex()
end

TimeManager.getVisualTime = function(self)
	local nearestTime = self:getNearestTime()
	if math.abs(self.currentTime - nearestTime) < 0.001 then
		return nearestTime
	end
	return self.currentTime
end

TimeManager.getTime = function(self)
	return self.currentTime
end

TimeManager.transformEventTime = function(self, eventTime)
	assert(eventTime - self.eventTime <= 0)
	return eventTime - self.eventTime + self.currentTime
end

return TimeManager
