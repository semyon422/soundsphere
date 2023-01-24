local Timer = require("Timer")

local TimeManager = Timer:new()

TimeManager.getAbsoluteTime = function(self)
	return self.eventTime or 0
end

TimeManager.getAbsoluteDelta = function(self)
	return self.eventDelta or 0
end

TimeManager.getAdjustTime = function(self)
	return self.audioManager:getPosition()
end

return TimeManager
