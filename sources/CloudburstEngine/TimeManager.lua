CloudburstEngine.TimeManager = createClass()
local TimeManager = CloudburstEngine.TimeManager

TimeManager.load = function(self)
	self.currentTime = -2
	self.state = "waiting"
	self.playState = "delayed"
end

TimeManager.update = function(self)
	if love.timer.getDelta() > 0.1 then
		return
	end
	
	if self.state == "waiting" then
	elseif self.state == "delayed" then
		if self.currentTime >= 0 then
			self.state = "started"
			self.playState = self.state
			if self.engine.audio then
				self.engine.audio:play()
			end
		else
			self.currentTime = self.currentTime + love.timer.getDelta()
		end
	elseif self.state == "started" or self.state == "playing" then
		if self.engine.audio then
			if self.engine.audio:isPaused() then
				self.engine.audio:play()
			end
			local audioCurrentTime = self.engine.audio:tell()
			if self.engine.audio:isStopped() then
				self.state = "ended"
				self.playState = self.state
			elseif self.state == "started" or audioCurrentTime ~= 0 then
				self.currentTime = audioCurrentTime
				if self.state == "started" then
					self.state = "playing"
					self.playState = self.state
				end
			end
		else
			self.currentTime = self.currentTime + love.timer.getDelta()
			self.state = "playing"
			self.playState = self.state
		end
	elseif self.state == "paused" then
		if not self.engine.audio:isPaused() then
			self.engine.audio:pause()
		end
	elseif self.state == "ended" then
		self.currentTime = self.currentTime + love.timer.getDelta()
	end
end

TimeManager.unload = function(self)

end

TimeManager.getCurrentTime = function(self)
	return self.currentTime
end

TimeManager.pause = function(self)
	self.state = "paused"
end

TimeManager.play = function(self)
	self.state = self.playState
end