local Timer = require("Timer")

local TimeManager = Timer + {}

function TimeManager:getAbsoluteTime()
	return self.eventTime or 0
end

function TimeManager:getAdjustTime()
	return self.timeEngine.rhythmModel.audioEngine:getPosition()
end

function TimeManager:getAudioOffsync()
	local audioTime, minPos, maxPos = self:getAdjustTime()
	local time = self:getTime()
	if audioTime then
		return audioTime - time, minPos - time, maxPos - time
	end
end

function TimeManager:transform(eventTime)
	assert(eventTime - self.eventTime <= 0)
	return Timer.transform(self, eventTime)
end

return TimeManager
