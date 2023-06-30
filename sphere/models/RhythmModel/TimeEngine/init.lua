local Class				= require("Class")
local math_util				= require("math_util")
local Observable		= require("Observable")
local TimeManager		= require("sphere.models.RhythmModel.TimeEngine.TimeManager")

local TimeEngine = Class:new()

TimeEngine.timeToPrepare = 2

TimeEngine.construct = function(self)
	self.observable = Observable:new()

	self.timer = TimeManager:new()
	self.timer.timeEngine = self
end

TimeEngine.startTime = 0
TimeEngine.currentTime = 0
TimeEngine.currentVisualTime = 0
TimeEngine.timeRate = 1
TimeEngine.targetTimeRate = 1
TimeEngine.baseTimeRate = 1
TimeEngine.inputOffset = 0
TimeEngine.visualOffset = 0
TimeEngine.windUp = nil

TimeEngine.load = function(self)
	self.timer:reset()
	self.timer:setRate(self.timeRate)
	self:loadTimePoints()

	local t = -self.timeToPrepare * self.baseTimeRate
	self.timer:setPosition(t)

	self.startTime = t
	self.currentTime = t
	self.currentVisualTime = t

	if self.noteChart then
		self.minTime = self.noteChart.metaData.minTime
		self.maxTime = self.noteChart.metaData.maxTime
	end
end

TimeEngine.sync = function(self, event)
	local timer = self.timer

	timer.eventTime = event.time
	timer.eventDelta = event.dt

	if self.windUp then
		self:updateWindUp()
	end

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

TimeEngine.updateWindUp = function(self)
	local startTime = self.noteChart.metaData.minTime
	local endTime = self.noteChart.metaData.maxTime
	local currentTime = self.currentTime

	local a, b = unpack(self.windUp)
	local timeRate = math_util.map(currentTime, startTime, endTime, a, b)
	timeRate = math.min(math.max(timeRate, a), b)

	self:setTimeRate(timeRate * self.baseTimeRate)
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

TimeEngine.setBaseTimeRate = function(self, timeRate)
	self.baseTimeRate = timeRate
	self:setTimeRate(timeRate)
end

TimeEngine.setTimeRate = function(self, timeRate)
	self.targetTimeRate = timeRate
	self.timeRate = timeRate
	self.timer:setRate(timeRate)
end

TimeEngine.loadTimePoints = function(self)
	local absoluteTimes = {}

	local noteChart = self.noteChart
	if not noteChart then
		return
	end
	for _, layerData in noteChart:getLayerDataIterator() do
		local timePointList = layerData.timePointList
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
