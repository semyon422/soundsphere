local Timer = require("aqua.util.Timer")

local TimeManager = Timer:new()

TimeManager.getAbsoluteTime = function(self)
	return self.eventTime
end

TimeManager.getAbsoluteDelta = function(self)
	return self.eventDelta
end

TimeManager.getAdjustTime = function(self)
	return self.timeEngine.rhythmModel.audioEngine:getPosition()
end

TimeManager.transformTime = function(self, eventTime)
	assert(eventTime - self.eventTime <= 0)
	return Timer.transformTime(self, eventTime)
end

return TimeManager
