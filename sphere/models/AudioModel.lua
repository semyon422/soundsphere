local class = require("class")
local audio = require("audio")

local AudioModel = class()

function AudioModel:load()
	local device = self.configModel.configs.settings.audio.device
	if device.period == 0 then
		device.period = audio.default_dev_period
	end
	if device.buffer == 0 then
		device.buffer = audio.default_dev_buffer
	end
	audio.setDevicePeriod(device.period)
	audio.setDeviceBuffer(device.buffer)
	audio.init()
end

return AudioModel
