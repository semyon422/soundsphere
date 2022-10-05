local loop = require("loop")
local Class = require("Class")

local FpsLimiter = Class:new()

FpsLimiter.update = function(self)
	local settings = self.game.configModel.configs.settings
	loop.fpslimit = settings.graphics.fps
	loop.asynckey = settings.graphics.asynckey
	loop.dwmflush = settings.graphics.dwmflush
	loop.imguiShowDemoWindow = settings.miscellaneous.imguiShowDemoWindow
end

return FpsLimiter
