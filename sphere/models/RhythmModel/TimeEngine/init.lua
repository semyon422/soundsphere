local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local tween				= require("tween")
local TimeManager		= require("sphere.models.RhythmModel.TimeEngine.TimeManager")

local TimeEngine = Class:new()

TimeEngine.timeToPrepare = 2

TimeEngine.construct = function(self)
	self.observable = Observable:new()

	self.timeManager = TimeManager:new()
	self.timeManager.timeEngine = self

	self.timeRateHandlers = {}
end

TimeEngine.currentTime = 0
TimeEngine.currentVisualTime = 0
TimeEngine.baseTimeRate = 1
TimeEngine.timeRate = 0
TimeEngine.targetTimeRate = 0
TimeEngine.backwardCounter = 0
TimeEngine.inputOffset = 0
TimeEngine.visualOffset = 0

TimeEngine.load = function(self)
	self.startTime = -self.timeToPrepare
	self.currentTime = self.startTime
	self.currentVisualTime = self.startTime
	self.baseTimeRate = TimeEngine.baseTimeRate
	self.timeRate = TimeEngine.timeRate
	self.targetTimeRate = TimeEngine.targetTimeRate
	self.backwardCounter = TimeEngine.backwardCounter

	self.timeManager:load()
	self.timeRateHandlers = {}

	self.minTime = self.noteChart.metaData:get("minTime")
	self.maxTime = self.noteChart.metaData:get("maxTime")
end

TimeEngine.updateTimeToPrepare = function(self)
	self.timeManager:setPosition(-self.timeToPrepare * self:getBaseTimeRate())
end

TimeEngine.createTimeRateHandler = function(self)
	local timeRateHandler = {
		timeRate = 1
	}

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

TimeEngine.sync = function(self, time, dt)
	local timeManager = self.timeManager

	timeManager.eventTime = time
	timeManager.eventDelta = dt

	if self.timeRateTween then
		self.timeRateTween:update(dt)
		timeManager:setRate(self.timeRate)
	end

	timeManager:update()

	self.currentTime = timeManager:getTime()
	self.currentVisualTime = timeManager:getVisualTime()
end

TimeEngine.unload = function(self) end

TimeEngine.skipIntro = function(self)
	local skipTime = self.minTime - self.timeToPrepare * math.abs(self.timeRate)
	if self.currentTime < skipTime and self.timeRate ~= 0 then
		self:setPosition(skipTime)
	end
end

TimeEngine.increaseTimeRate = function(self, delta)
	if self.targetTimeRate + delta >= 0.1 then
		self.targetTimeRate = self.targetTimeRate + delta
		self:setTimeRate(self.targetTimeRate)
	end
end

TimeEngine.setPosition = function(self, position)
	self.rhythmModel.audioEngine:setPosition(position)
	self.timeManager:setPosition(position)
	self.timeManager:adjustTime(true)
	self:sync()

	self.rhythmModel.audioEngine.forcePosition = true
	self.rhythmModel.logicEngine:update()
	self.rhythmModel.audioEngine.forcePosition = false
end

TimeEngine.setTimeRate = function(self, timeRate, needTween)
	if timeRate == 0 and self.timeRate ~= 0 then
		self.timeManager:pause()
		self.timeRate = 0
		self.targetTimeRate = 0
	elseif timeRate ~= 0 and self.timeRate == 0 then
		self.timeManager:play()
		self.timeRate = timeRate
		self.targetTimeRate = timeRate
		self.timeManager:setRate(timeRate)
	elseif timeRate == 0 and self.timeRate == 0 then
		return
	elseif not needTween then
		self.timeRate = timeRate
		self.targetTimeRate = timeRate
		self.timeManager:setRate(timeRate)
	else
		self.timeRateTween = tween.new(0.25, self, {timeRate = timeRate}, "inOutQuad")
	end
end

return TimeEngine
