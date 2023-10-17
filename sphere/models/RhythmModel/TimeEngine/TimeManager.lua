local Timer = require("Timer")

---@class sphere.RhythmTimeManager: util.Timer
---@operator call: sphere.RhythmTimeManager
local TimeManager = Timer + {}

---@return number
function TimeManager:getAbsoluteTime()
	return self.eventTime or 0
end

---@return number?
---@return number?
---@return number?
function TimeManager:getAdjustTime()
	return self.timeEngine.audioEngine:getPosition()
end

---@return number?
---@return number?
---@return number?
function TimeManager:getAudioOffsync()
	local audioTime, minPos, maxPos = self:getAdjustTime()
	local time = self:getTime()
	if audioTime then
		return audioTime - time, minPos - time, maxPos - time
	end
end

---@param eventTime number
---@return number
function TimeManager:transform(eventTime)
	assert(eventTime - self.eventTime <= 0)
	return Timer.transform(self, eventTime)
end

return TimeManager
