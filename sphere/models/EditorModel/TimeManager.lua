local Timer = require("Timer")

---@class sphere.EditorTimeManager: util.Timer
---@operator call: sphere.EditorTimeManager
local TimeManager = Timer + {}

---@return number
function TimeManager:getAbsoluteTime()
	return self.eventTime or 0
end

---@return number?
function TimeManager:getAdjustTime()
	return self.editorModel.mainAudio:getPosition()
end

---@return number?
function TimeManager:getAudioOffsync()
	local audioTime = self:getAdjustTime()
	local time = self:getTime()
	if audioTime then
		return audioTime - time
	end
end

return TimeManager
