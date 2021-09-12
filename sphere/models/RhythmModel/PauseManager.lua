local Class = require("aqua.util.Class")
local tween = require("tween")

local PauseManager = Class:new()

PauseManager.load = function(self)
	self.state = "play"
	self.progress = 0
	self.needRetry = false
end

PauseManager.setPauseTimes = function(self, timePlayPause, timePausePlay, timePlayRetry, timePauseRetry)
	self.progressTime = {
		["play-pause"] = timePlayPause,
		["pause-play"] = timePausePlay,
		["play-retry"] = timePlayRetry,
		["pause-retry"] = timePauseRetry,
	}
end

PauseManager.update = function(self, dt)
	if self.progressTween then
		self.progressTween:update(dt)
	else
		self.progress = 0
	end

	self:updateState()

	if self.progress == 1 then
		self.progress = 0
	end
end

PauseManager.updateState = function(self)
	local state = self.state
	local progress = self.progress

	if state == "play-pause" then
		if progress == 1 then
			self:pause()
			self.state = "pause"
		end
	elseif state == "pause-play" then
		if progress == 1 then
			self:play()
			self.state = "play"
		end
	elseif state:find("retry") then
		if progress == 1 then
			self:retry()
			self.state = "play"
		end
	end
end

PauseManager.receive = function(self, event)
	if event.name == "focus" and self.state ~= "pause" and not event.args[1] and not self.logicEngine.autoplay then
		self:pause()
	end

	local state = self.state
	local progressTime = self.progressTime
	if event.name == "playStateChange" then
		local progressState = state .. "-" .. event.state
		local time
		if not progressTime[state] and progressTime[progressState] then
			state = progressState
			time = progressTime[progressState]
		elseif progressTime[state] and state:sub(1, #event.state) == event.state then
			state = event.state
		end
		self.state = state
		self:startProgress(time)
	end
end

PauseManager.startProgress = function(self, time)
	self.progress = 0
	if not time then
		self.progressTween = nil
		return
	elseif time == 0 then
		self.progress = 1
		return self:updateState()
	end
	self.progressTween = tween.new(time, self, {progress = 1}, "linear")
end

PauseManager.play = function(self)
	self.timeEngine:setTimeRate(self.timeEngine:getBaseTimeRate())
end

PauseManager.pause = function(self)
	self.timeEngine:setTimeRate(0)
end

PauseManager.retry = function(self)
	self.needRetry = true
end

return PauseManager
