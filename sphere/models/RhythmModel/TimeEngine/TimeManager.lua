local Timer = require("Timer")

local TimeManager = Timer:new()

TimeManager.getAbsoluteTime = function(self)
	return self.eventTime or 0
end

TimeManager.getAbsoluteDelta = function(self)
	return self.eventDelta or 0
end

TimeManager.getAdjustTime = function(self)
	return self.timeEngine.rhythmModel.audioEngine:getPosition()
end

TimeManager.getAudioOffsync = function(self)
	local audioTime, minPos, maxPos = self:getAdjustTime()
	local time = self:getTime()
	if audioTime then
		return audioTime - time, minPos - time, maxPos - time
	end
end

TimeManager.transformTime = function(self, eventTime)
	assert(eventTime - self.eventTime <= 0)
	return Timer.transformTime(self, eventTime)
end

return TimeManager
