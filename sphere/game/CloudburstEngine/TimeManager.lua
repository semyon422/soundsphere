local Class = require("aqua.util.Class")

local TimeManager = Class:new()

TimeManager.rate = 1

TimeManager.load = function(self)
	self.currentTime = -1
	self.pauseTime = 0
	self.rateDelta = 0
	self.state = "waiting"
	self.playState = "delayed"
end

TimeManager.update = function(self)
	local deltaTime = love.timer.getTime() - (self.startTime or 0)
	
	if self.state == "waiting" then
	elseif self.state == "delayed" then
		if self.currentTime >= 0 then
			self.state = "started"
			self.playState = self.state
		else
			self.currentTime = (deltaTime - self.pauseTime - self.rateDelta) * self.rate
		end
	elseif self.state == "started" or self.state == "playing" then
		self.state = "playing"
		self.playState = self.state
		
		self.currentTime = (deltaTime - self.pauseTime - self.rateDelta) * self.rate
	elseif self.state == "paused" then
		
	elseif self.state == "ended" then
		self.currentTime = (deltaTime - self.pauseTime - self.rateDelta) * self.rate
	end
end

TimeManager.unload = function(self)

end

TimeManager.setRate = function(self, rate)
	if self.startTime then
		local pauseTime
		if self.state == "paused" then
			pauseTime = self.pauseTime + love.timer.getTime() - self.pauseStartTime
		else
			pauseTime = self.pauseTime
		end
		local deltaTime = love.timer.getTime() - self.startTime - pauseTime
		self.rateDelta = (self.rateDelta - deltaTime) * self.rate / rate + deltaTime
	end
	self.rate = rate
end

TimeManager.getCurrentTime = function(self)
	return self.currentTime
end

TimeManager.pause = function(self)
	self.state = "paused"
	self.pauseStartTime = love.timer.getTime()
end

TimeManager.play = function(self)
	if self.state == "waiting" then
		self.state = self.playState
		self.startTime = love.timer.getTime() - self.currentTime
	elseif self.state == "paused" then
		self.state = "playing"
		self.pauseTime = self.pauseTime + love.timer.getTime() - self.pauseStartTime
		self.pauseStartTime = love.timer.getTime()
	end
end

return TimeManager
