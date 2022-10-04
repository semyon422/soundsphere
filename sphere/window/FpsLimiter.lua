local gameloop = require("gameloop")
local Class = require("Class")

local FpsLimiter = Class:new()

FpsLimiter.update = function(self)
	local settings = self.game.configModel.configs.settings
	gameloop.fpslimit = settings.graphics.fps
	gameloop.asynckey = settings.graphics.asynckey
	gameloop.dwmflush = settings.graphics.dwmflush
	gameloop.imguiShowDemoWindow = settings.miscellaneous.imguiShowDemoWindow
end

return FpsLimiter
