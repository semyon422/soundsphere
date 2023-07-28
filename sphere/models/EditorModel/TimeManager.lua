local Timer = require("Timer")

local TimeManager = Timer:new()

TimeManager.getAbsoluteTime = function(self)
	return self.eventTime or 0
end

TimeManager.getAdjustTime = function(self)
	return self.editorModel.mainAudio:getPosition()
end

TimeManager.getAudioOffsync = function(self)
	local audioTime = self:getAdjustTime()
	local time = self:getTime()
	if audioTime then
		return audioTime - time
	end
end

return TimeManager
