local Class = require("Class")
local bass = require("audio.bass")

local AudioModel = Class:new()

AudioModel.load = function(self)
	local device = self.game.configModel.configs.settings.audio.device
	if device.period == 0 then
		device.period = bass.default_dev_period
	end
	if device.buffer == 0 then
		device.buffer = bass.default_dev_buffer
	end
	bass.setDevicePeriod(device.period)
	bass.setDeviceBuffer(device.buffer)
	bass.init()
end

return AudioModel
