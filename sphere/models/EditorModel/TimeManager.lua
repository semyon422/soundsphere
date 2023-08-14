local Timer = require("Timer")

local TimeManager = Timer + {}

function TimeManager:getAbsoluteTime()
	return self.eventTime or 0
end

function TimeManager:getAdjustTime()
	return self.editorModel.mainAudio:getPosition()
end

function TimeManager:getAudioOffsync()
	local audioTime = self:getAdjustTime()
	local time = self:getTime()
	if audioTime then
		return audioTime - time
	end
end

return TimeManager
