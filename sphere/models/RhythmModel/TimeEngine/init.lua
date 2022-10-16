local Class				= require("Class")
local Observable		= require("Observable")
local TimeManager		= require("sphere.models.RhythmModel.TimeEngine.TimeManager")

local TimeEngine = Class:new()

TimeEngine.timeToPrepare = 2

TimeEngine.construct = function(self)
	self.observable = Observable:new()

	self.timer = TimeManager:new()
	self.timer.timeEngine = self
end

TimeEngine.currentTime = 0
TimeEngine.currentVisualTime = 0
TimeEngine.timeRate = 1
TimeEngine.targetTimeRate = 1
TimeEngine.inputOffset = 0
TimeEngine.visualOffset = 0
TimeEngine.baseTimeRate = 1

TimeEngine.load = function(self)
	self.startTime = -self.timeToPrepare
	self.currentTime = self.startTime
	self.currentVisualTime = self.startTime
	self.timeRate = 1
	self.targetTimeRate = 1
	self.baseTimeRate = 1

	self.timer:reset()
	self:loadTimePoints()
	self:resetTimeRateHandlers()

	self.minTime = self.noteChart.metaData:get("minTime")
	self.maxTime = self.noteChart.metaData:get("maxTime")
end

TimeEngine.updateTimeToPrepare = function(self)
	self.timer:setPosition(-self.timeToPrepare * self:getBaseTimeRate())
end

TimeEngine.resetTimeRateHandlers = function(self)
	self.timeRateHandlers = {}
end

TimeEngine.createTimeRateHandler = function(self)
	local timeRateHandler = {timeRate = 1}

	local timeRateHandlers = self.timeRateHandlers
	timeRateHandlers[#timeRateHandlers + 1] = timeRateHandler

	return timeRateHandler
end

TimeEngine.getBaseTimeRate = function(self)
	local timeRate = 1
	local timeRateHandlers = self.timeRateHandlers
	for i = 1, #timeRateHandlers do
		timeRate = timeRate * timeRateHandlers[i].timeRate
	end
	self.baseTimeRate = timeRate
	return timeRate
end

TimeEngine.resetTimeRate = function(self)
	self:setTimeRate(self:getBaseTimeRate())
end

TimeEngine.sync = function(self, event)
	local timer = self.timer

	timer.eventTime = event.time
	timer.eventDelta = event.dt

	if self.timeRate ~= self.targetTimeRate then
		timer:setRate(self.timeRate)
	end

	timer:update()
	self.currentTime = timer:getTime()

	if not self.nextTimeIndex then
		return
	end
	self:updateNextTimeIndex()
	self.currentVisualTime = self:getVisualTime()
end

TimeEngine.getVisualTime = function(self)
	local nearestTime = self:getNearestTime()
	local currentTime = self.currentTime
	if math.abs(currentTime - nearestTime) < 0.001 then
		return nearestTime
	end
	return currentTime
end

TimeEngine.skipIntro = function(self)
	local skipTime = self.minTime - self.timeToPrepare * math.abs(self.timeRate)
	if self.currentTime < skipTime and self.timer.isPlaying then
		self:setPosition(skipTime)
	end
end

TimeEngine.increaseTimeRate = function(self, delta)
	local target = self.targetTimeRate
	local newTarget = math.floor((target + delta) / delta + 0.5) * delta

	if newTarget >= 0.1 then
		self:setTimeRate(newTarget)
	end
end

TimeEngine.setPosition = function(self, position)
	local timer = self.timer
	local audioEngine = self.rhythmModel.audioEngine

	audioEngine:setPosition(position)
	timer:setPosition(position)
	timer:adjustTime(true)
	self.currentTime = timer:getTime()
	self.currentVisualTime = self:getVisualTime()

	audioEngine.forcePosition = true
	self.rhythmModel.logicEngine:update()
	audioEngine.forcePosition = false
end

TimeEngine.pause = function(self)
	self.timer:pause()
end

TimeEngine.play = function(self)
	self.timer:play()
end

TimeEngine.setTimeRate = function(self, timeRate)
	self.targetTimeRate = timeRate
	self.timeRate = timeRate
	self.timer:setRate(timeRate)
end

TimeEngine.loadTimePoints = function(self)
	local absoluteTimes = {}

	local noteChart = self.noteChart
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

TimeEngine.updateNextTimeIndex = function(self)
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

TimeEngine.getNearestTime = function(self)
	local timeList = self.absoluteTimeList
	local prevTime = timeList[self.nextTimeIndex - 1]
	local nextTime = timeList[self.nextTimeIndex]

	if not prevTime then
		return nextTime
	end

	local currentTime = self.currentTime
	local prevDelta = math.abs(currentTime - prevTime)
	local nextDelta = math.abs(currentTime - nextTime)

	return prevDelta < nextDelta and prevTime or nextTime
end

return TimeEngine
