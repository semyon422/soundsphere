local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local tween				= require("tween")
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

TimeEngine.load = function(self)
	self.startTime = -self.timeToPrepare
	self.currentTime = self.startTime
	self.currentVisualTime = self.startTime
	self.timeRate = 1
	self.targetTimeRate = 1

	self.timer:reset()
	self:loadTimePoints()
	self.timeRateHandlers = {}

	self.minTime = self.noteChart.metaData:get("minTime")
	self.maxTime = self.noteChart.metaData:get("maxTime")
end

TimeEngine.updateTimeToPrepare = function(self)
	self.timer:setPosition(-self.timeToPrepare * self:getBaseTimeRate())
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
	return timeRate
end

TimeEngine.resetTimeRate = function(self)
	self:setTimeRate(self:getBaseTimeRate())
end

TimeEngine.sync = function(self, event)
	local timer = self.timer

	timer.eventTime = event.time
	timer.eventDelta = event.dt

	if self.timeRateTween then
		self.timeRateTween:update(event.dt)
		timer:setRate(self.timeRate)
		if timer.rate == self.targetTimeRate then
			self.timeRateTween = nil
		end
	end

	timer:update()
	self:updateNextTimeIndex()

	self.currentTime = timer:getTime()
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
	if self.targetTimeRate + delta >= 0.1 then
		self:setTimeRate(self.targetTimeRate + delta)
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

TimeEngine.setTimeRate = function(self, timeRate, needTween)
	self.targetTimeRate = timeRate
	if needTween then
		self.timeRateTween = tween.new(0.25, self, {timeRate = timeRate}, "inOutQuad")
		return
	end
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
