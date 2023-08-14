local class = require("class")
local flux = require("flux")

local PauseManager = class()

function PauseManager:load()
	self.state = "play"
	self.progress = 0
	self.needRetry = false
end

function PauseManager:setPauseTimes(config)
	self.progressTime = {
		["play-pause"] = config.playPause,
		["pause-play"] = config.pausePlay,
		["play-retry"] = config.playRetry,
		["pause-retry"] = config.pauseRetry,
	}
end

function PauseManager:update(dt)
	self:updateState()

	if self.progress == 1 then
		self.progress = 0
	end
end

function PauseManager:updateState()
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

function PauseManager:changePlayState(newState)
	local state = self.state
	local progressTime = self.progressTime
	local progressState = state .. "-" .. newState
	local time
	if not progressTime[state] and progressTime[progressState] then
		state = progressState
		time = progressTime[progressState]
	elseif progressTime[state] and state:sub(1, #newState) == newState then
		state = newState
	end
	self.state = state
	self:startProgress(time)
end

function PauseManager:startProgress(time)
	self.progress = 0
	if self.tween then
		self.tween:stop()
	end
	if not time then
		return
	elseif time == 0 then
		self.progress = 1
		return self:updateState()
	end
	self.tween = flux.to(self, time, {progress = 1}):ease("linear")
end

function PauseManager:play()
	self.rhythmModel.timeEngine:play()
	self.rhythmModel.audioEngine:play()
	self.rhythmModel.inputManager:loadState()
	self.state = "play"
	love.mouse.setVisible(false)
end

function PauseManager:pause()
	self.rhythmModel.timeEngine:pause()
	self.rhythmModel.audioEngine:pause()
	self.rhythmModel.inputManager:saveState()
	self.state = "pause"
	love.mouse.setVisible(true)
end

function PauseManager:retry()
	self.needRetry = true
	self.state = "play"
end

return PauseManager
