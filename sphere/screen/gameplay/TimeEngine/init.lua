local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local tween				= require("tween")
local Config			= require("sphere.config.Config")
local TimeManager		= require("sphere.screen.gameplay.TimeEngine.TimeManager")

local TimeEngine = Class:new()

TimeEngine.construct = function(self)
	self.observable = Observable:new()

	self.baseTimeRates = {1}
end

TimeEngine.currentTime = 0
TimeEngine.exactCurrentTime = 0
TimeEngine.baseTimeRate = 1
TimeEngine.timeRate = 0
TimeEngine.targetTimeRate = 0

TimeEngine.load = function(self)
	self:loadTimeManager()
end

TimeEngine.addBaseTimeRate = function(self, timeRate)
	local baseTimeRates = self.baseTimeRates
	baseTimeRates[#baseTimeRates + 1] = timeRate
end

TimeEngine.getBaseTimeRate = function(self)
	local timeRate = 1
	local baseTimeRates = self.baseTimeRates
	for i = 1, #baseTimeRates do
		timeRate = timeRate * baseTimeRates[i]
	end
	return timeRate
end

TimeEngine.update = function(self, dt)	
	if self.timeRateTween then
		self.timeRateTween:update(dt)
		self.timeManager:setRate(self.timeRate)
	end
	
	self:updateTimeManager(dt)

	self.currentTime = self.timeManager:getTime()
	self.exactCurrentTime = self.timeManager:getExactTime()
	self.observable:send({
		name = "TimeState",
		currentTime = self.currentTime,
		exactCurrentTime = self.exactCurrentTime,
		timeRate = self.timeRate
	})
end

TimeEngine.unload = function(self)
	self:unloadTimeManager()
end

TimeEngine.receive = function(self, event)
	if event.name == "keypressed" then
		local key = event.args[1]
		local delta = 0.05
		
		if key == Config:get("gameplay.decreaseTimeRate") then
			if self.targetTimeRate - delta >= 0.1 then
				self.targetTimeRate = self.targetTimeRate - delta
				self:setTimeRate(self.targetTimeRate)
			end
			return self.observable:send({
				name = "notify",
				text = "timeRate: " .. self.targetTimeRate
			})
		elseif key == Config:get("gameplay.increaseTimeRate") then
			self.targetTimeRate = self.targetTimeRate + delta
			self:setTimeRate(self.targetTimeRate)
			return self.observable:send({
				name = "notify",
				text = "timeRate: " .. self.targetTimeRate
			})
		end
	end
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

TimeEngine.loadTimeManager = function(self)
	self.timeManager = TimeManager:new()
	self.timeManager.timeEngine = self
	self.timeManager:load()
end

TimeEngine.updateTimeManager = function(self, dt)
	self.timeManager:update(dt)
end

TimeEngine.unloadTimeManager = function(self)
	self.timeManager:unload()
end

return TimeEngine
