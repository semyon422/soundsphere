local Class = require("aqua.util.Class")
local tween = require("tween")

local PauseManager = Class:new()

PauseManager.load = function(self)
	self.state = "play"
	self.progress = 0
	self.needRetry = false
end

PauseManager.setPauseTimes = function(self, config)
	self.progressTime = {
		["play-pause"] = config.playPause,
		["pause-play"] = config.pausePlay,
		["play-retry"] = config.playRetry,
		["pause-retry"] = config.pauseRetry,
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
		end
	elseif state == "pause-play" then
		if progress == 1 then
			self:play()
		end
	elseif state:find("retry") then
		if progress == 1 then
			self:retry()
		end
	end
end

PauseManager.receive = function(self, event)
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
	self.rhythmModel.timeEngine:play()
	self.rhythmModel.audioEngine:play()
	self.rhythmModel.inputManager:loadState()
	self.state = "play"
	love.mouse.setVisible(false)
end

PauseManager.pause = function(self)
	self.rhythmModel.timeEngine:pause()
	self.rhythmModel.audioEngine:pause()
	self.rhythmModel.inputManager:saveState()
	self.state = "pause"
	love.mouse.setVisible(true)
end

PauseManager.retry = function(self)
	self.needRetry = true
	self.state = "play"
end

return PauseManager
