local Class = require("aqua.util.Class")
local tween = require("tween")

local PauseManager = Class:new()

PauseManager.progressTime = {
	["play-pause"] = 0.20,
	["pause-play"] = 0.5,
	["play-retry"] = 0.5,
	["pause-retry"] = 0.5,
}

PauseManager.load = function(self)
	self.state = "play"
	self.progress = 0
	self.needRetry = false
end

PauseManager.update = function(self, dt)
	if self.progressTween then
		self.progressTween:update(dt)
	else
		self.progress = 0
	end

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

	if progress == 1 then
		self.progress = 0
	end
end

PauseManager.receive = function(self, event)
	-- if event.name == "focus" and not self.paused and not event.args[1] and not self.rhythmModel.logicEngine.autoplay then
	-- 	self:pause()
	-- end

	local state = self.state
	local progressTime = self.progressTime
	if event.name == "playStateChange" then
		local progressState = state .. "-" .. event.state
		if not progressTime[state] and progressTime[progressState] then
			state = progressState
			self:startProgress(progressTime[progressState])
		elseif progressTime[state] and state:sub(1, #event.state) == event.state then
			state = event.state
			self:startProgress()
		end
		self.state = state
	end
end

PauseManager.startProgress = function(self, time)
	self.progress = 0
	if not time then
		self.progressTween = nil
		return
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
