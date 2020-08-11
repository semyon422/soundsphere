local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local tween				= require("tween")
local GameConfig		= require("sphere.config.GameConfig")
local TimeManager		= require("sphere.models.RhythmModel.TimeEngine.TimeManager")

local TimeEngine = Class:new()

TimeEngine.construct = function(self)
	self.observable = Observable:new()

	self.timeManager = TimeManager:new()
	self.timeManager.timeEngine = self

	self.timeRateHandlers = {}
end

TimeEngine.currentTime = 0
TimeEngine.exactCurrentTime = 0
TimeEngine.baseTimeRate = 1
TimeEngine.timeRate = 0
TimeEngine.targetTimeRate = 0
TimeEngine.backwardCounter = 0

TimeEngine.load = function(self)
	self.currentTime = TimeEngine.currentTime
	self.exactCurrentTime = TimeEngine.exactCurrentTime
	self.baseTimeRate = TimeEngine.baseTimeRate
	self.timeRate = TimeEngine.timeRate
	self.targetTimeRate = TimeEngine.targetTimeRate
	self.backwardCounter = TimeEngine.backwardCounter

	self.timeManager:load()
	self.timeRateHandlers = {}
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
	self.exactCurrentTime = timeManager:getExactTime()
	self:sendState()
end

TimeEngine.sendState = function(self)
	return self.observable:send({
		name = "TimeState",
		time = self.exactCurrentTime,
		currentTime = self.currentTime,
		exactCurrentTime = self.exactCurrentTime,
		timeRate = self.timeRate
	})
end

TimeEngine.unload = function(self)
	self.timeManager:unload()
end

TimeEngine.receive = function(self, event)
	if event.name == "framestarted" then
		self:sync(event.time, event.dt)
	end
	-- if event.name == "keypressed" then
	-- 	local key = event.args[1]
	-- 	local delta = 0.05

	-- 	if key == GameConfig:get("gameplay.decreaseTimeRate") then
	-- 		if self.targetTimeRate - delta >= 0.1 then
	-- 			self.targetTimeRate = self.targetTimeRate - delta
	-- 			self:setTimeRate(self.targetTimeRate)
	-- 		end
	-- 		return self.observable:send({
	-- 			name = "notify",
	-- 			text = "timeRate: " .. self.targetTimeRate
	-- 		})
	-- 	elseif key == GameConfig:get("gameplay.increaseTimeRate") then
	-- 		self.targetTimeRate = self.targetTimeRate + delta
	-- 		self:setTimeRate(self.targetTimeRate)
	-- 		return self.observable:send({
	-- 			name = "notify",
	-- 			text = "timeRate: " .. self.targetTimeRate
	-- 		})
	-- 	elseif key == GameConfig:get("gameplay.invertTimeRate") then
	-- 		self:setTimeRate(-self.timeRate)
	-- 	elseif key == GameConfig:get("gameplay.skipIntro") then
	-- 		local skipTime = self.noteChart.metaData:get("minTime") - 2
	-- 		if self.currentTime < skipTime and self.timeRate ~= 0 then
	-- 			self:setPosition(skipTime)
	-- 		end
	-- 	end
	-- end
end

TimeEngine.setPosition = function(self, position)
	self.audioEngine:setPosition(position)
	self.timeManager:setPosition(position)
	self:update(0)

	self.audioEngine.forcePosition = true
	self.logicEngine:update()
	self.audioEngine.forcePosition = false
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
	elseif not needTween then
		self.timeRate = timeRate
		self.targetTimeRate = timeRate
		self.timeManager:setRate(timeRate)
	else
		self.timeRateTween = tween.new(0.25, self, {timeRate = timeRate}, "inOutQuad")
	end
end

return TimeEngine
