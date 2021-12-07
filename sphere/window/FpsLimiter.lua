local aquaevent = require("aqua.event")
local Class = require("aqua.util.Class")

local FpsLimiter = Class:new()

FpsLimiter.update = function(self)
	local settings = self.configModel.configs.settings
	aquaevent.fpslimit = settings.graphics.fps
	aquaevent.asynckey = settings.graphics.asynckey
	aquaevent.dwmflush = settings.graphics.dwmflush
	aquaevent.predictDrawTime = settings.graphics.predictDrawTime
end

return FpsLimiter
