local aquaevent = require("aqua.event")
local Class = require("aqua.util.Class")

local FpsLimiter = Class:new()

FpsLimiter.update = function(self)
	local settings = self.configModel:getConfig("settings")
	aquaevent.fpslimit = settings.graphics.fps
end

return FpsLimiter
